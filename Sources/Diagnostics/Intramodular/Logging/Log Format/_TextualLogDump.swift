//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct _TextualLogDump: _LogFormat {
    public var entries: [Entry]
    
    public init(entries: [Entry]) {
        self.entries = entries
    }
    
    public init() {
        self.init(entries: [])
    }
    
    public func _textualDump() throws -> _TextualLogDump {
        self
    }
}

// MARK: - Conformances

extension _TextualLogDump: Codable {
    public init(from decoder: Decoder) throws {
        do {
            self.entries = try Array<Entry>(from: decoder)
        } catch {
            self.entries = try Array<String>(from: decoder).map {
                Entry(timestamp: nil, scope: nil, level: nil, message: $0)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try entries.encode(to: encoder)
    }
}

// MARK: - Auxiliary

extension _TextualLogDump {
    public struct Scope: Codable, Hashable, Sendable {
        public typealias RawValue = String
        
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public init(from decoder: Decoder) throws {
            try self.init(rawValue: RawValue(from: decoder))
        }
        
        public func encode(to encoder: Encoder) throws {
            try rawValue.encode(to: encoder)
        }
    }
    
    public struct Entry: Codable, Hashable, Sendable {
        public let timestamp: Date?
        public let scope: [Scope]?
        public let level: String?
        public let message: String
        
        public init(
            timestamp: Date?,
            scope: [_TextualLogDump.Scope]?,
            level: String?,
            message: String
        ) {
            self.timestamp = timestamp
            self.scope = scope
            self.level = level
            self.message = message
        }
    }
}
