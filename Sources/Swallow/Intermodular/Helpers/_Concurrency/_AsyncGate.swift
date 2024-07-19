//  Created by Wade Tregaskis on 2024-03-05.
import Foundation // For NSRecursiveLock.  TODO: remove this dependency on Foundation (extract the `NSRecursiveLock` implementation into a standalone package?).  TODO: make this `@usableFromInline internal` once `@usableFromInline` is correctly supported.  https://forums.swift.org/t/usablefrominline-not-supported-on-imports-in-swift-6/72379/2

/// Controls execution of async task(s) like a gate that can be opened or closed, with tasks having to wait to enter while it's closed.
///
/// The gate may be opened and closed by any code, sync or async.  However, only async code may enter the gate, by calling `await gate.enter()`.
///
/// There is no limit to how many tasks may be waiting for the gate to open.
///
/// It is a fatal error (i.e. your program crashes!) to deinit the gate while it is closed and tasks are waiting to enter it.  Either ensure that no tasks are waiting to enter the gate when it is deinited, or ensure the gate is open when it is deinited.
///
/// ### Performance
///
/// `Gate` uses traditional recursive mutexes under the covers.  This allows it to be safely used concurrently from multiple threads / tasks / isolation contexts.  That does mean that it blocks if there's contention on the mutex when you try to ``open()``, ``close()``, or ``enter()`` the gate.  However, it is designed to hold the lock only _very_ briefly while updating very simple internal state, so these periods of blocking should generally be very brief, to the point of being entirely insignificant.
///
/// If there is _very_ high _concurrent_ activity on the gate (from multiple threads), the blocking duration can conceivably become noticeable (as time spent inside `Gate` methods).  This is very unlikely outside of pathological uses.
///
/// Note that it will always make forward progress - it is safe to use with Swift Concurrency.
public final class _AsyncGate: @unchecked Sendable {
    /// - Parameter initiallyOpen: Whether the gate is initially open (tasks may enter through the gate freely) or closed (tasks must wait to enter, until the gate is opened).
    @inlinable
    public init(initiallyOpen: Bool) {
        self.isOpen = initiallyOpen
    }
    
    /// Opens the gate, allowing tasks to enter.
    ///
    /// This has no effect if the gate is already open.
    public func open() {
        self.lock.lock()
        
        guard !self.isOpen else {
            self.lock.unlock()
            return
        }
        
        let suspensions = self.suspensions
        self.suspensions.removeAll()
        
        self.lock.unlock()
        
        suspensions.forEach {
            $0.resume()
        }
    }
    
    /// Closed the gate, forcing all _future_ attempts to enter the gate to wait until it opens again.
    ///
    /// Note that any tasks which have _already_ entered through the gate will not be affected (unless they subsequently try to enter through the gate again).
    ///
    /// This has no effect if the gate is already closed.
    @inlinable
    public func close() {
        self.lock.lock()
        self.isOpen = false
        self.lock.unlock()
    }
    
    /// Enter through the gate, waiting for it to open first as necessary.
    /// - Throws: ``CancellationError`` if the task is cancelled at the time it tries to enter the gate, or while waiting to enter the gate.
    public func enter() async throws {
        try Task.checkCancellation()
        
        self.lockWithoutTheCompilerBitchingAtUs()
        
        if self.isOpen {
            self.unlockWithoutTheCompilerBitchingAtUs()
        } else {
            let suspension = Suspension(state: .pending)
            
            try await withTaskCancellationHandler {
                try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
                    if case .cancelled = suspension.state {
                        // The `onCancel` closure below was invoked before we got here.
                        self.lock.unlock()
                        continuation.resume(throwing: CancellationError())
                    } else {
                        suspension.state = .suspended(continuation)
                        self.suspensions.append(suspension)
                        self.lock.unlock()
                    }
                }
            } onCancel: {
                // withTaskCancellationHandler may call this at any time, including before the actual body (above) runs.  In that particular case, we're still holding the lock, thus the need for a _recursive_ lock.
                self.lock.lock()
                
                if let index = self.suspensions.firstIndex(where: { $0 === suspension }) {
                    self.suspensions.remove(at: index)
                }
                
                if case let .suspended(continuation) = suspension.state {
                    self.lock.unlock()
                    continuation.resume(throwing: CancellationError())
                } else {
                    suspension.state = .cancelled
                    self.lock.unlock()
                }
            }
        }
    }
    
    private final class Suspension: @unchecked Sendable {
        enum State {
            /// Initial state. Next is suspended or cancelled.
            case pending
            
            /// Waiting for the gate to open, with support for cancellation.
            case suspended(UnsafeContinuation<Void, any Error>)
            
            /// Cancelled before we started waiting.
            case cancelled
        }
        
        var state: State
        
        init(state: State) {
            self.state = state
        }
        
        func resume() {
            if case let .suspended(continuation) = self.state {
                continuation.resume()
            }
        }
    }
    
    @usableFromInline
    internal var isOpen: Bool
    
    private var suspensions = [Suspension]()
    
    @usableFromInline
    internal let lock = NSRecursiveLock() // Protects all state (i.e. the above two variables).
    
    private func lockWithoutTheCompilerBitchingAtUs() {
        self.lock.lock()
    }
    
    private func unlockWithoutTheCompilerBitchingAtUs() {
        self.lock.unlock()
    }
    
    deinit {
        precondition(self.suspensions.isEmpty, "Gate deallocated while some task(s) are suspended waiting for the gate to open.")
    }
}
