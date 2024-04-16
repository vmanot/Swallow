//
// Copyright (c) Vatsal Manot
//

import Swift

private enum _PlaceholderGenerationFailure: CustomStringConvertible, Error {
    case unsupportedType(Any.Type)
     
    var description: String {
        switch self {
            case .unsupportedType(let type):
                return "Failed to generate a placeholder for type: \(type)"
        }
    }
}

public func _generatePlaceholder<Result>(
    ofType type: Result.Type = Result.self
) throws -> Result {
    switch type {
        case is Void.Type:
            return () as! Result
        case let type as any _HasPlaceholder.Type:
            return type.init(_opaque_placeholder: ()) as! Result
        case let type as _PlaceholderInitiable.Type:
            return type.init() as! Result
        case let type as PlaceholderProviding.Type:
            return type.placeholder as! Result
        case let type as ExpressibleByNilLiteral.Type:
            return type.init(nilLiteral: ()) as! Result
        case let type as Initiable.Type:
            return type.init() as! Result
        case let type as any RangeReplaceableCollection.Type:
            return type.placeholder as! Result
        case let type as any AdditiveArithmetic.Type:
            return type.placeholder as! Result
        case let type as any ExpressibleByArrayLiteral.Type:
            return type.placeholder as! Result
        case let type as any ExpressibleByBooleanLiteral.Type:
            return type.placeholder as! Result
        case let type as any ExpressibleByDictionaryLiteral.Type:
            return type.placeholder as! Result
        case let type as any ExpressibleByFloatLiteral.Type:
            return type.placeholder as! Result
        case let type as any ExpressibleByIntegerLiteral.Type:
            return type.placeholder as! Result
        case let type as any ExpressibleByUnicodeScalarLiteral.Type:
            return type.placeholder as! Result
        case let type as _ThrowingInitiable.Type:
            return try type.init() as! Result
        default:
            assert(Result.self != Any.self)
            
            throw _PlaceholderGenerationFailure.unsupportedType(Result.self)
    }
}

public func _opaque_generatePlaceholder(
    ofType type: Any.Type
) throws -> Any {
    func _generatePlaceholderOfType<T>(_ type: T.Type) throws -> Any {
        return try (_generatePlaceholder() as T) as Any
    }
    
    return try _openExistential(type, do: _generatePlaceholderOfType)
}

@_disfavoredOverload
public func _generatePlaceholder(
    ofType type: Any.Type
) throws -> Any {
    try _opaque_generatePlaceholder(ofType: type)
}

@_disfavoredOverload
public func _generatePlaceholder<R>(
    ofType type: Any.Type,
    as _: R.Type
) throws -> R {
    try cast(_opaque_generatePlaceholder(ofType: type), to: R.self)
}

// MARK: - Internal

private func _caseIterable<Result>() -> Result? {
    func firstCase<T: CaseIterable>(for type: T.Type) -> Result? {
        T.allCases.first as? Result
    }
    
    return (Result.self as? any CaseIterable.Type).flatMap {
        firstCase(for: $0)
    }
}

private func _rawRepresentable<Result>() -> Result? {
    func posiblePlaceholder<T: RawRepresentable>(for type: T.Type) -> T? {
        (try? _generatePlaceholder() as T.RawValue?).flatMap(T.init(rawValue:))
    }
    
    return (Result.self as? any RawRepresentable.Type).flatMap {
        posiblePlaceholder(for: $0) as? Result
    }
}

extension AdditiveArithmetic {
    fileprivate static var placeholder: Self {
        .zero
    }
}

extension ExpressibleByArrayLiteral {
    fileprivate static var placeholder: Self {
        []
    }
}

extension ExpressibleByBooleanLiteral {
    fileprivate static var placeholder: Self {
        false
    }
}

extension ExpressibleByDictionaryLiteral {
    fileprivate static var placeholder: Self {
        [:]
    }
}

extension ExpressibleByFloatLiteral {
    fileprivate static var placeholder: Self {
        0.0
    }
}

extension ExpressibleByIntegerLiteral {
    fileprivate static var placeholder: Self {
        0
    }
}

extension ExpressibleByUnicodeScalarLiteral {
    fileprivate static var placeholder: Self {
        " "
    }
}

extension RangeReplaceableCollection {
    fileprivate static var placeholder: Self {
        Self()
    }
}

extension Array where Element == Any.Type {
    public func _initializeAll<T>(as type: T.Type = T.self) throws -> [T] {
        try map { element in
            if let element = element as? Initiable.Type {
                return try cast(element.init())
            } else {
                return try _generatePlaceholder(ofType: element, as: T.self)
            }
        }
    }
}
