//
// Copyright (c) Vatsal Manot
//

import Swift

private enum _PlaceholderGenerationFailure: Error {
    case unsupportedType(Any.Type)
}

public func _generatePlaceholder(
    ofType type: Any.Type
) throws -> Any {
    func _generatePlaceholderOfType<T>(_ type: T.Type) throws -> Any {
        return try (_generatePlaceholder() as T) as Any
    }
    
    return try _openExistential(type, do: _generatePlaceholderOfType)
}

public func _generatePlaceholder<Result>(
    ofType type: Result.Type = Result.self
) throws -> Result {
    switch Result.self {
        case let type as any _HasPlaceholder.Type:
            return type.init(_opaque_placeholder: ()) as! Result
        case let type as _PlaceholderInitiable.Type:
            return type.init() as! Result
        case let type as PlaceholderProviding.Type:
            return type.placeholder as! Result
        case let type as Initiable.Type:
            return type.init() as! Result
        case is Void.Type:
            return () as! Result
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
        default:
            throw _PlaceholderGenerationFailure.unsupportedType(Result.self)
    }
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
