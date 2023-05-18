//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct AnyNominalOrTupleMirror: MirrorType, FailableWrapper {
    public var value: Any
    public let typeMetadata: TypeMetadata.NominalOrTuple
    
    private let _cachedFieldsByName: [AnyStringKey: NominalTypeMetadata.Field]
    
    public var supertypeMirror: AnyNominalOrTupleMirror? {
        guard let supertypeMetadata = typeMetadata.supertypeMetadata else {
            return nil
        }
        
        return .init(
            unchecked: self.value as Any,
            typeMetadata: supertypeMetadata
        )
    }
    
    init(
        unchecked value: Any,
        typeMetadata: TypeMetadata.NominalOrTuple
    ) {
        self.value = value
        self.typeMetadata = typeMetadata
        self._cachedFieldsByName = Dictionary(OrderedDictionary(values: typeMetadata.fields, uniquelyKeyedBy: { AnyStringKey(stringValue: $0.name) }))
    }
    
    public init(unchecked value: Value) {
        self.init(unchecked: value, typeMetadata: .of(value))
    }
    
    public init?(_ value: Value) {
        guard let _ = TypeMetadata.NominalOrTuple(type(of: value)) else {
            return nil
        }
        
        self.init(unchecked: value)
    }
}

// MARK: - Conformances

extension AnyNominalOrTupleMirror: CustomStringConvertible {
    public var description: String {
        return String(describing: value)
    }
}

extension AnyNominalOrTupleMirror: KeyExposingMutableDictionaryProtocol {
    public var fields: [NominalTypeMetadata.Field] {
        typeMetadata.fields
    }
    
    public var allFields: [NominalTypeMetadata.Field] {
        guard let supertypeMirror = supertypeMirror else {
            return fields
        }
        
        return .init(supertypeMirror.allFields.join(fields))
    }
    
    public var keys: [AnyStringKey] {
        fields.map({ .init(stringValue: $0.name) })
    }
    
    public var allKeys: [AnyStringKey] {
        allFields.map({ .init(stringValue: $0.name) })
    }
    
    public subscript(field: NominalTypeMetadata.Field) -> Any {
        get {
            return OpaqueExistentialContainer.withUnretainedValue(value) {
                $0.withUnsafeBytes { bytes in
                    field.type.opaqueExistentialInterface.copyValue(
                        from: bytes.baseAddress?.advanced(by: field.offset)
                    )
                }
            }
        } set {
            assert(type(of: newValue) == field.type.base)

            OpaqueExistentialContainer.withUnretainedValue(&value) {
                $0.withUnsafeMutableBytes { bytes in
                    field.type.opaqueExistentialInterface.reinitializeValue(
                        at: bytes.baseAddress?.advanced(by: field.offset),
                        to: newValue
                    )
                }
            }
        }
    }
    
    public subscript(_ key: AnyStringKey) -> Any? {
        get {
            fieldForKey(key).map({ self[$0] })
        } set {
            guard let field = fieldForKey(key) else {
                return
            }
            
            guard let newValue = newValue else {
                return assertionFailure()
            }
            
            self[field] = newValue
        }
    }
    
    private func fieldForKey(_ key: AnyStringKey) -> NominalTypeMetadata.Field? {
        _cachedFieldsByName[key] ?? typeMetadata.allFields.first(where: { $0.key == key })
    }
}

extension AnyNominalOrTupleMirror: Sequence {
    public typealias Element = (key: AnyStringKey, value: Any)
    public typealias Children = AnySequence<Element>
    public typealias AllChildren = AnySequence<Element>
    
    public var children: Children {
        .init(self)
    }
    
    public var allChildren: Children {
        guard let supertypeMirror = supertypeMirror else {
            return children
        }
        
        return .init(supertypeMirror.allChildren.join(children))
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        AnyIterator(keys.lazy.map(({ ($0, self[$0]!) })).makeIterator())
    }
}
