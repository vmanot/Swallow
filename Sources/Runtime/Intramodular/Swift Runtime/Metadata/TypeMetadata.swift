//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@frozen
public struct TypeMetadata: _TypeMetadataType {
    public let base: Any.Type
    
    public var size: Int {
        get {
            swift_getSize(of: base)
        }
    }
    
    @_transparent
    public init(_ base: Any.Type) {
        self.base = base
    }
    
    @_optimize(speed)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        ObjectIdentifier(lhs.base) == ObjectIdentifier(rhs.base)
    }
    
    public static func of(_ x: Any) -> Self {
        TypeMetadata(Swift.type(of: x))
    }
    
    public init?(name: String) {
        guard let type: Any.Type = _typeByName(name) else {
            return nil
        }
        
        self.init(type)
    }
    
    public init?(
        name: String,
        mangledName: String?
    ) {
        guard let type: Any.Type = _typeByName(name) ?? mangledName.flatMap(_typeByName) else {
            return nil
        }
        
        self.init(type)
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

extension TypeMetadata: Named {
    public var hasUnderscoredName: Bool {
        _unqualifiedName.hasPrefix("_")
    }
    
    public var _name: String {
        _typeName(base)
    }
    
    public var _qualifiedName: String {
        _typeName(base, qualified: true)
    }
    
    public var _unqualifiedName: String {
        _typeName(base, qualified: false)
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public var mangledName: String? {
        _mangledTypeName(base)
    }
    
    public var name: String {
        _qualifiedName
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

extension TypeMetadata {
    /// Determines if the current type is covariant to the specified type.
    ///
    /// Covariance allows a type to be used in place of its supertype. For example,
    /// if type `B` is a subtype of type `A`, then `B` is covariant to `A`.
    ///
    /// - Parameter other: The type to check for covariance against.
    /// - Returns: `true` if the current type is covariant to the specified type, otherwise `false`.
    public func _isCovariant(to other: TypeMetadata) -> Bool {
        func _checkIsCovariant<T>(_ type: T.Type) -> Bool {
            func _isCovariant<U>(to otherType: U.Type) -> Bool {
                let result = type == otherType || type is U.Type
                
                if !result {
                    if let type = type as? AnyClass, let otherType = otherType as? AnyClass {
                        return unsafeBitCast(type, to: NSObject.Type.self).isSubclass(of: unsafeBitCast(otherType, to: NSObject.Type.self))
                    }
                }
                
                return result
            }
            
            return _openExistential(other.base, do: _isCovariant(to:))
        }
        
        return _openExistential(self.base, do: _checkIsCovariant)
    }
}

// MARK: - Internal

private func swift_getSize(
    of type: Any.Type
) -> Int {
    func project<T>(_ type: T.Type) -> Int {
        MemoryLayout<T>.size
    }
    
    return _openExistential(type, do: project)
}
