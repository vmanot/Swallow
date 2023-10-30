//
// Copyright (c) Vatsal Manot
//

import Swallow

@frozen
public struct TypeMetadata: _TypeMetadata_Type {
    public let base: Any.Type
        
    public init(_ base: Any.Type) {
        self.base = base
    }
}

// MARK: - Conformances

extension TypeMetadata: CustomStringConvertible {
    public var description: String {
        String(describing: base)
    }
}

extension TypeMetadata: MetatypeRepresentable {
    public init(metatype: Any.Type) {
        self.init(metatype)
    }
    
    public func toMetatype() -> Any.Type {
        return base
    }
}

// MARK: - Supplementary

/// Returns whether a given value is a type of a type (a metatype).
///
/// ```swift
/// isMetatype(Int.self) // false
/// isMetatype(Int.Type.self) // true
/// ```
public func _isTypeOfType<T>(_ x: T) -> Bool {
    guard let type = x as? Any.Type else {
        return false
    }
    
    let metadata = TypeMetadata(type)
    
    switch metadata.kind {
        case .metatype, .existentialMetatype:
            return true
        default:
            return false
    }
}

extension Metatype {
    /// ```swift
    /// Metatype(Int.self)._isTypeOfType // false
    /// Metatype(Int.Type.self)._isTypeOfType // true
    /// ```
    public var _isTypeOfType: Bool {
        Runtime._isTypeOfType(self._unwrapBase())
    }
    
    /// `Optional<T>.Type` -> `T.Type`
    ///
    /// Notes:
    /// - Not to be confused with `Optional<T.Type>` -> `T.Type`.
    public var unwrapped: Metatype<Any.Type> {
        Metatype<Any.Type>(_getUnwrappedType(from: _unwrapBase()))
    }
}
