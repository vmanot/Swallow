//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@propertyWrapper
public struct _StaticMirrorQuery<T, U> {
    public let type: T.Type
    public let wrappedValue: [U]
    
    public init(type: T.Type, transform: ([U]) -> [U] = { $0 }) {
        self.type = type
        
        let value: [U] = try! TypeMetadata._queryAll(.nonAppleFramework, .conformsTo(type))
        
        self.wrappedValue = transform(value)
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "StaticMirrorQuery")
public typealias RuntimeDiscoveredTypes<T, U> = _StaticMirrorQuery<T, U>

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
