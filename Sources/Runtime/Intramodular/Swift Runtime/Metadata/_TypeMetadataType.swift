//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A `TypeMetadata`-like type.
public protocol _TypeMetadataType: Hashable {
    var base: Any.Type { get }
    
    /// The supertype of this type, if any.
    var supertypeMetadata: Self? { get }
    
    var _isInvalid: Bool { get }
    
    init(_unchecked base: Any.Type)
    init?(_ base: Any.Type)
}

/// A `NominalTypeMetadata`-like type.
public protocol _NominalTypeMetadataType: CustomStringConvertible, _TypeMetadataType {
    var mangledName: String { get }
    var supertypeFields: [NominalTypeMetadata.Field]? { get }
    var fields: [NominalTypeMetadata.Field] { get }
}

// MARK: - Implementation

extension _TypeMetadataType {
    public var _isInvalid: Bool {
        String(describing: base).contains("<<< invalid type >>>")
    }
}

extension CustomStringConvertible where Self: _TypeMetadataType {
    public var description: String {
        String(describing: base)
    }
}

extension Equatable where Self: _TypeMetadataType {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

extension Hashable where Self: _TypeMetadataType {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
}

extension _TypeMetadataType {
    public var supertypeMetadata: Self? {
        guard let value = (base as? AnyClass).map(ObjCClass.init) else {
            return nil
        }
        
        guard let superclass = value.superclass else {
            return nil
        }
                
        return .init(_unchecked: superclass.value)
    }
    
    public init(_unchecked base: Any.Type) {
        self = Self(base)!
    }
}

extension _NominalTypeMetadataType {
    public var supertypeFields: [NominalTypeMetadata.Field]? {
        supertypeMetadata?.fields
    }
}

// MARK: - Extensions

extension _TypeMetadataType {
    package var _isBaseSwiftObject: Bool {
        guard let cls = ObjCClass(base) else {
            return false
        }
        
        return cls.isBaseSwiftObject
    }
    
    @_disfavoredOverload
    public static func of<T>(_ value: T) -> Self? {
        Self(type(of: value as Any))
    }
}

extension _NominalTypeMetadataType {
    public var allFields: [NominalTypeMetadata.Field] {
        (supertypeMetadata?.allFields ?? []) + fields
    }
}
