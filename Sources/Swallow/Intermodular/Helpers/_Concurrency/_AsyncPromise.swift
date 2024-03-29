//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

public final class _AsyncPromise<Success, Failure: Error>: ObservableObject, @unchecked Sendable {
    public typealias FulfilledValue = Result<Success, Failure>
    
    private let lock = OSUnfairLock()
    
    private var _suspensions: [UnsafeContinuation<FulfilledValue, Never>]
    private var _isCancelled: Bool = false
    private var _fulfilledValue: FulfilledValue?
    
    public var fulfilledResult: FulfilledValue? {
        lock.withCriticalScope {
            _fulfilledValue
        }
    }
    
    public init() {
        self._suspensions = []
        self._fulfilledValue = nil
    }
    
    public convenience init(_ value: Success) {
        self.init()
        
        self._fulfilledValue = .success(value)
    }
    
    public convenience init(
        _ fulfill: @escaping (UnsafeContinuation<Success, Failure>) -> Void
    ) where Failure == Swift.Error {
        self.init()
        
        Task {
            let result = await Result(catching: {
                try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Success, Failure>) in
                    fulfill(continuation)
                }
            })
            
            do {
                try Task.checkCancellation()
                
                self.fulfill(with: result)
            } catch {
                self.fulfill(with: .failure(error))
            }
        }
    }
    
    public convenience init(
        _ value: @escaping () async throws -> Success
    ) where Failure == Error {
        self.init()
        
        Task {
            await self.fulfill(with: Result(catching: { try await value() }))
        }
    }
        
    public func fulfill(with result: Result<Success, Failure>) {
        lock.withCriticalScope {
            guard _fulfilledValue == nil else {
                assertionFailure(_Error.promiseAlreadyFulfilled)
                
                return
            }
            
            guard !_isCancelled else {
                do {
                    let cancellationError = try cast(Result<Success, Error>.failure(CancellationError()), to: Result<Success, Failure>.self)
                    
                    _suspensions.forEach({ $0.resume(returning: cancellationError) })
                    _suspensions = []
                } catch {
                    assertionFailure(error)
                }
                
                return
            }
            
            objectWillChange.send()

            _fulfilledValue = result
            
            _suspensions.forEach({ $0.resume(with: .success(result)) })
            _suspensions.removeAll()
        }
    }
    
    public func fulfill(returning success: Success) {
        self.fulfill(with: .success(success))
    }
    
    public func fulfill(throwing error: Failure) {
        self.fulfill(with: .failure(error))
    }

    public func fulfill() where Success == Void {
        self.fulfill(with: .success(()))
    }
    
    public func cancel() where Failure == Error {
        lock.withCriticalScope {
            _isCancelled = true
            
            _suspensions.forEach({ $0.resume(with: .success(.failure(CancellationError()))) })
            _suspensions.removeAll()
        }
    }
    
    public func result() async -> Result<Success, Failure> {
        if let result = lock.withCriticalScope(perform: { _fulfilledValue }) {
            return result
        }
        
        return await withUnsafeContinuation { continuation in
            lock.withCriticalScope {
                if let result = _fulfilledValue {
                    continuation.resume(with: .success(result))
                } else {
                    self._suspensions.append(continuation)
                }
            }
        }
    }
}

// MARK: - Extensions -

extension _AsyncPromise {
    public func fulfill(with success: Success) {
        fulfill(with: .success(success))
    }
    
    public func fulfill() where Success == Void, Failure == Never {
        fulfill(with: ())
    }

    public func fulfill(with failure: Failure) {
        fulfill(with: .failure(failure))
    }
    
    public func get() async throws -> Success {
        try await result().get()
    }
    
    public func get() async -> Success where Failure == Never {
        await self.result().get()
    }
}

extension _AsyncPromise {
    public var isFulfilled: Bool {
        fulfilledResult != nil
    }
}

extension _AsyncPromise where Failure == Never {
    public var fulfilledValue: Success? {
        fulfilledResult?.get()
    }
}

extension _AsyncPromise where Failure == Error {
    public var fulfilledValue: Success? {
        get throws {
            try fulfilledResult?.get()
        }
    }
}

// MARK: - Conformances

extension _AsyncPromise: Cancellable where Failure == Error {
    
}

// MARK: - Error Handling

extension _AsyncPromise {
    fileprivate enum _Error: Swift.Error {
        case promiseAlreadyFulfilled
    }
}
