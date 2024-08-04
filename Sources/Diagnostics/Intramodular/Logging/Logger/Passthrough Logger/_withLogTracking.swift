//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift

public func _withLogTracking<R>(
    perform operation: @escaping () throws -> R,
    handler: @Sendable (PassthroughLogger.LogEntry) -> Void
) rethrows -> R {
    try withoutActuallyEscaping(handler) { handler in
        let handler: @Sendable (PassthroughLogger.LogEntry) -> Void = handler
        
        let result: R = try _TaskLocalValues.$_logEntryHandler.withValue(handler) {
            try operation()
        }
        
        return result
    }
}

public func _withLogTracking<R>(
    perform operation: @escaping () async throws -> R,
    handler: @escaping @Sendable (PassthroughLogger.LogEntry) -> Void
) async rethrows -> R {
    let handler: @Sendable (PassthroughLogger.LogEntry) -> Void = handler
    
    let result: R = try await _TaskLocalValues.$_logEntryHandler.withValue(handler) {
        try await operation()
    }
    
    return result
}

// MARK: - Auxiliary

extension _TaskLocalValues {
    @TaskLocal
    static var _logEntryHandler: (@Sendable (PassthroughLogger.LogEntry) -> Void)?
}
