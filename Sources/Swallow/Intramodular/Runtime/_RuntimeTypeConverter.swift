//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@objc open class _AnyRuntimeTypeConverter: NSObject {
    open class var type: Any.Type? {
        nil
    }
}

public protocol _RuntimeTypeConverterProtocol: _AnyRuntimeTypeConverter {
    
}

@_alwaysEmitConformanceMetadata
public protocol _NonGenericRuntimeTypeConverterProtocol: _RuntimeTypeConverterProtocol {
    associatedtype Source
    associatedtype Destination
    
    static func __convert(_ source: Source) throws -> Destination
}

@_alwaysEmitConformanceMetadata
public protocol _GenericRuntimeTypeConverterProtocol: _RuntimeTypeConverterProtocol {
    static func __converts<T, U>(source: T.Type, to destination: U.Type) -> Bool?
    static func __converts<T, U>(source: T, to destination: U.Type) -> Bool?
    static func __convert<T, U>(source: T, to destination: U.Type) throws -> U
}

extension _GenericRuntimeTypeConverterProtocol {
    public static func __converts<T, U>(source: T, to destination: U.Type) -> Bool? {
        if let result = __converts(source: Swift.type(of: source), to: destination) {
            if !result {
                return false
            }
        }
        
        return nil
    }
}

public enum _RuntimeTypeConverters: _StaticSwift.Namespace {
    
}

extension _RuntimeTypeConverters {
    public struct IdentifierIndexingArray_to_Array {
        public static func __converts<T, U>(
            source: T.Type,
            to destination: U.Type
        ) -> Bool? {
            if source is any _IdentifierIndexingArrayOf_Protocol.Type && destination is any _ArrayProtocol.Type {
                return true
            }
            
            return nil
        }
        
        public static func __convert<T, U>(
            source: T,
            to destination: U.Type
        ) throws -> U {
            let source: any _IdentifierIndexingArrayOf_Protocol = try _forceCast(source)
            let destination: any _ArrayProtocol.Type = try _forceCast(destination)
            
            func _convert<X: _IdentifierIndexingArrayOf_Protocol>(_ x: X) throws -> U {
                func _convert<Y: _ArrayProtocol>(_ destinationType: Y.Type) throws -> U {
                    if X.Element.self == Y.Element.self {
                        return try x._ProtocolizableType_withInstance {
                            return try cast(Array($0), to: U.self)
                        }
                    } else {
                        fatalError(.unimplemented)
                    }
                }
                
                return try _openExistential(destination, do: _convert)
            }
            
            return try _openExistential(source, do: _convert)
        }
    }
}

public enum RuntimeCoercionError: CustomStringConvertible, LocalizedError {
    case coercionFailed(from: Any.Type, to: Any.Type, value: Any, location: SourceCodeLocation)
    
    public var description: String {
        switch self {
            case let .coercionFailed(sourceType, destinationType, value, location): do {
                var description: String
                
                if let value = Optional(_unwrapping: value) {
                    description = "Could not coerce \(value) to '\(destinationType)'"
                } else {
                    description = "Could not coerce value of type '\(sourceType)' to '\(destinationType)'"
                }
                
                if let file = location.file, file != #file {
                    description = "\(location): \(description)"
                }
                
                return description
            }
        }
    }
}

public func coerce<T, U>(
    _ x: T,
    to targetType: U.Type,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> U {
    throw RuntimeCoercionError.coercionFailed(
        from: type(of: x),
        to: targetType,
        value: x,
        location: .unavailable
    )
}
