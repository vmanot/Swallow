//
// Copyright (c) Vatsal Manot
//

/// WIP lane for MDC-style diagnostic context.
///
/// Scope stack answers where a log happened in nested work. Context bindings
/// will answer what structured facts should travel with that work.
public protocol _LogContextBindingRepresentable {
    var _logContextBindings: [_LogContextBinding] { get }
}

public struct _LogContextBinding: Hashable, Sendable {
    public struct Key: Hashable, Sendable, ExpressibleByStringLiteral {
        public var rawValue: String
        
        public init(
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
        
        public init(
            stringLiteral value: String
        ) {
            self.init(rawValue: value)
        }
    }
    
    public enum Value: Hashable, Sendable, CustomStringConvertible {
        case string(String)
        case int(Int)
        case bool(Bool)
        case double(Double)
        case description(String)
        
        public var description: String {
            switch self {
                case .string(let value):
                    return value
                case .int(let value):
                    return value.description
                case .bool(let value):
                    return value.description
                case .double(let value):
                    return value.description
                case .description(let value):
                    return value
            }
        }
    }
    
    public var key: Key
    public var value: Value
    
    public init(
        key: Key,
        value: Value
    ) {
        self.key = key
        self.value = value
    }
}
