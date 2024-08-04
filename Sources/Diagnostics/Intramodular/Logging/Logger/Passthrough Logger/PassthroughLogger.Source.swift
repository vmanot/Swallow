//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension PassthroughLogger {
    public struct Source: CustomStringConvertible {
        public enum Content {
            case sourceCodeLocation(SourceCodeLocation)
            case logger(any LoggerProtocol, scope: AnyLogScope?)
            case something(Any)
            case object(Weak<AnyObject>)
            case type(Any.Type)
        }
        
        private let content: Content
        
        public var description: String {
            switch content {
                case .sourceCodeLocation(let location):
                    return location.description
                case .logger(let logger, let scope):
                    if let logger = logger as? _PassthroughLogger {
                        guard let scope else {
                            assertionFailure()
                            
                            return String(describing: logger)
                        }
                        
                        return "\(logger.source.description): \(scope.description)"
                    } else {
                        assertionFailure()
                        
                        return String(describing: logger)
                    }
                case .something(let value):
                    return String(describing: value)
                case .object(let object):
                    if let object = object.wrappedValue {
                        return String(describing: object)
                    } else {
                        return "(null)"
                    }
                case .type(let type):
                    return String(describing: type)
            }
        }
        
        private init(content: Content) {
            if content is any LoggerProtocol {
                assertionFailure()
            }
            
            self.content = content
        }
        
        public static func location(_ location: SourceCodeLocation) -> Self {
            Self(content: .sourceCodeLocation(location))
        }
        
        public static func logger(
            _ logger: any LoggerProtocol,
            scope: AnyLogScope
        ) -> Self {
            Self(content: .logger(logger, scope: scope))
        }
        
        public static func object(
            _ object: AnyObject
        ) -> Self {
            if object is any LoggerProtocol {
                assertionFailure()
            }
            
            return Self(content: .object(Weak(wrappedValue: object)))
        }
        
        public static func type(
            _ type: Any.Type
        ) -> Self {
            return Self(content: .type(type))
        }
        
        public static func something(
            _ thing: Any
        ) -> Self {
            if swift_isClassType(Swift.type(of: thing)) {
                return .object(thing as AnyObject)
            } else {
                return .init(content: .something(thing))
            }
        }
    }
    
    public struct Configuration {
        @TaskLocal static var global = Self()
        
        public var _dumpToConsole: Bool?
        
        public init(
            _dumpToConsole: Bool? = nil
        ) {
            self._dumpToConsole = _dumpToConsole
        }
    }
}
