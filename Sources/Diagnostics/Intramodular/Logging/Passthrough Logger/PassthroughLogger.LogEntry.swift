//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension PassthroughLogger {
    public struct Message: Codable, CustomStringConvertible, Hashable, LogMessageProtocol {
        public typealias StringLiteralType = String
        
        private var rawValue: String
        
        public var description: String {
            rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        public init(from decoder: Decoder) throws {
            try self.init(rawValue: .init(from: decoder))
        }
        
        public func encode(to encoder: Encoder) throws {
            try rawValue.encode(to: encoder)
        }
    }
    
    public struct LogEntry: Hashable {
        public let sourceCodeLocation: SourceCodeLocation?
        public let timestamp: Date
        public let scope: PassthroughLogger.Scope
        public let level: LogLevel
        public let message: LogMessage
    }
}
