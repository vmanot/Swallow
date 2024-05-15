//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type-erased `Task`.
///
/// The success value is type-erased to `any Sendable`.
public struct OpaqueTask: Sendable {
    private let _completion: @Sendable () async -> any Sendable
    private let _cancel: @Sendable () -> Void
    
    /// Wait for the task to complete, returning (or throwing) its result.
    public var value: any Sendable {
        get async {
            await _completion()
        }
    }
    
    public init<Success>(
        erasing task: Task<Success, Never>
    ) {
        self._completion = {
            await task.value
        }
        
        self._cancel = {
            task.cancel()
        }
    }
    
    /// Attempt to cancel the task.
    public func cancel() {
        _cancel()
    }
}

/// A type-erased Task.
public struct OpaqueThrowingTask: Sendable {
    private let _completion: @Sendable () async throws -> any Sendable
    private let _cancel: @Sendable () -> Void
    
    /// Wait for the task to complete, returning (or throwing) its result.
    public var value: any Sendable {
        get async throws {
            try await _completion()
        }
    }
    
    public init<Success, Failure>(erasing task: Task<Success, Failure>) {
        self._completion = {
            try await task.value
        }
        
        self._cancel = {
            task.cancel()
        }
    }
    
    /// Attempt to cancel the task.
    public func cancel() {
        _cancel()
    }
}

extension Task {
    /// Returns a type-erased version of self.
    public func eraseToOpaqueThrowingTask() -> OpaqueThrowingTask {
        .init(erasing: self)
    }
}

// MARK: - SwiftUI Additions

extension Task {
    /// Bind this task to a `Binding`.
    ///
    /// - Parameters:
    ///   - taskBinding: The `Binding` to set when this task starts, and clear when this task ends/errors out.
    public func bind(
        @_UncheckedSendable to taskBinding: Binding<OpaqueThrowingTask?>
    ) {
        let erasedTask = OpaqueThrowingTask(erasing: self)
        
        _Concurrency.Task { @MainActor in
            _taskBinding.wrappedValue.wrappedValue = erasedTask
            
            _ = try await self.value
            
            _taskBinding.wrappedValue.wrappedValue = nil
        }
    }
}
