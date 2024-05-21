//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

public final class _ManagedActorTaskQueue: Sendable {
    private struct _State: Sendable {
        var isTaskInProgress: Bool = false
    }
    
    private let state = _OSUnfairLocked<_State>(wrappedValue: .init())
    private let queue: _Queue
    
    public init() {
        self.queue = .init()
    }
    
    /// Returns whether there are tasks currently executing.
    public nonisolated var isActive: Bool {
        queue.hasActiveTasks
    }
    
    /// Spawns a task to add an action to perform, with optional debouncing.
    ///
    /// This method can be called from a synchronous context.
    ///
    /// - Parameters:
    ///   - action: An async function to execute.
    ///   - debounceInterval: Minimum time interval to wait after a task before starting the next one.
    public func addTask<T: Sendable>(
        priority: TaskPriority? = nil,
        @_implicitSelfCapture operation: @Sendable @escaping () async -> T
    ) {
        Task {
            await queue.addTask(
                priority: priority,
                operation: operation
            )
        }
    }
    
    /// Performs an action right after the previous action has been finished, with debouncing.
    ///
    /// - Parameters:
    ///   - action: An async function to execute. The function may throw and return a value.
    ///   - debounceInterval: Minimum time interval to wait after a task before starting the next one.
    /// - Returns: The return value of `action`
    public func perform<T: Sendable>(
        @_implicitSelfCapture operation: @Sendable @escaping () async -> T
    ) async -> T {
        guard _Queue.queueID?.erasedAsAnyHashable != queue.id.erasedAsAnyHashable else {
            return await operation()
        }
        
        return await withUnsafeContinuation { continuation in
            addTask {
                continuation.resume(returning: await operation())
            }
        }
    }
    
    public func cancelAll() {
        Task {
            await queue.cancelAll()
        }
    }
    
    public func waitForAll() async {
        await queue.waitForAll()
    }
}

extension _ManagedActorTaskQueue {
    fileprivate actor _Queue: Sendable {
        private struct _State: Sendable {
            var previousTask: OpaqueTask? = nil
        }
        
        private nonisolated let state = _OSUnfairLocked<_State>(wrappedValue: .init())
        
        let id: (any Hashable & Sendable) = UUID()
        
        nonisolated var hasActiveTasks: Bool {
            state.previousTask != nil
        }
        
        func cancelAll() {
            state.previousTask?.cancel()
            state.previousTask = nil
        }
        
        func addTask<T: Sendable>(
            priority: TaskPriority?,
            operation: @Sendable @escaping () async -> T
        ) -> Task<T, Never> {
            guard Self.queueID?.erasedAsAnyHashable != id.erasedAsAnyHashable else {
                fatalError()
            }
            
            let previousTask = self.state.previousTask
            let newTask = Task(priority: priority) { () async -> T in
                if let previousTask = previousTask {
                    _ = await previousTask.value
                }
                
                return await Self.$queueID.withValue(id) {
                    await operation()
                }
            }
            
            self.state.previousTask = OpaqueTask(erasing: newTask)
            
            return newTask
        }
        
        func waitForAll() async {
            guard let last = state.previousTask else {
                return
            }
            
            _ = await last.value
        }
    }
}

extension _ManagedActorTaskQueue._Queue {
    @TaskLocal
    fileprivate static var queueID: (any Hashable & Sendable)?
}
