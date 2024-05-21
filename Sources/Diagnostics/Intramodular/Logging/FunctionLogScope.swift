//
// Copyright (c) Vatsal Manot
//

import Swallow

extension PassthroughLogger {
    public func log<Result>(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line,
        column: UInt? = #column,
        operation: () throws -> Result
    ) throws -> Result {
        let scopedLogger = #try(.optimistic) {
            try PassthroughLogger().scoped(to: FunctionLogScope(function: function))
        }
        
        scopedLogger?.log(level: .debug, "[enter]", metadata: nil, file: file, function: function, line: line)
        
        do {
            defer {
                scopedLogger?.log(
                    level: .debug, "[exit]",
                    metadata: nil,
                    file: file,
                    function: function,
                    line: line
                )
            }
            
            return try operation()
        } catch {
            scopedLogger?.log(
                level: .error,
                "[error]: \(String(describing: error))",
                metadata: nil,
                file: file,
                function: function,
                line: line
            )
            
            throw error
        }
    }
    
    public func log<Result>(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line,
        column: UInt? = #column,
        operation: () async throws -> Result
    ) async throws -> Result {
        let scopedLogger = #try(.optimistic) {
            try self.scoped(to: FunctionLogScope(function: function))
        }
        
        scopedLogger?.log(level: .debug, "[enter]", metadata: nil, file: file, function: function, line: line)
        
        do {
            defer {
                scopedLogger?.log(
                    level: .debug, "[exit]",
                    metadata: nil,
                    file: file,
                    function: function,
                    line: line
                )
            }
            
            return try await operation()
        } catch {
            scopedLogger?.log(
                level: .error,
                "[error]: \(String(describing: error))",
                metadata: nil,
                file: file,
                function: function,
                line: line
            )
            
            throw error
        }
    }
}

public struct FunctionLogScope: Hashable, LogScope {
    public let function: String
    
    public var description: String {
        function.description
    }
    
    public init(function: String) {
        self.function = function
    }
    
    public init(function: StaticString) {
        self.function = function.description
    }
}
