//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A `TypeMetadata`-like type.
public protocol _TypeMetadata_Type: Hashable {
    var base: Any.Type { get }
    
    /// The supertype of this type, if any.
    var supertypeMetadata: Self? { get }
    
    init(_unsafe base: Any.Type)
    init?(_ base: Any.Type)
}

/// A `NominalTypeMetadata`-like type.
public protocol NominalTypeMetadata_Type: CustomStringConvertible, _TypeMetadata_Type {
    var mangledName: String { get }
    
    var supertypeFields: [NominalTypeMetadata.Field]? { get }
    var fields: [NominalTypeMetadata.Field] { get }
}

// MARK: - Implementation

extension CustomStringConvertible where Self: _TypeMetadata_Type {
    public var description: String {
        String(describing: base)
    }
}

extension Equatable where Self: _TypeMetadata_Type {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

extension Hashable where Self: _TypeMetadata_Type {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
}

extension _TypeMetadata_Type {
    public var supertypeMetadata: Self? {
        guard let value = (base as? AnyClass).map(ObjCClass.init) else {
            return nil
        }
        
        guard let superclass = value.superclass else {
            return nil
        }
                
        return .init(_unsafe: superclass.value)
    }
    
    public init(_unsafe base: Any.Type) {
        self = Self(base)!
    }
}

extension NominalTypeMetadata_Type {
    public var supertypeFields: [NominalTypeMetadata.Field]? {
        supertypeMetadata?.fields
    }
}

// MARK: - Extensions

extension _TypeMetadata_Type {
    public var isSwiftObject: Bool {
        ObjCClass(base)?.isSwiftObject ?? false
    }
    
    public static func of<T>(_ value: T) -> Self! {
        Self(type(of: value as Any))
    }
}

extension NominalTypeMetadata_Type {
    public var allFields: [NominalTypeMetadata.Field] {
        (supertypeMetadata?.allFields ?? []) + fields
    }
}
