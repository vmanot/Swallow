//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _AnyMirrorType<Subject> {
    associatedtype Subject
    
    func _accept(
        visitor: _AnyMirrorVisitor,
        at path: [_AnyMirrorPathElement]
    ) throws
}

public struct AnyNominalOrTupleMirror<Subject>: _AnyMirrorType, MirrorType {
    public var subject: Any
    public let typeMetadata: TypeMetadata.NominalOrTuple
    
    @available(*, deprecated, renamed: "subject")
    public var value: Any {
        subject
    }
    
    private let _cachedFieldsByName: [AnyCodingKey: NominalTypeMetadata.Field]
    
    public var supertypeMirror: AnyNominalOrTupleMirror<Any>? {
        guard let supertypeMetadata = typeMetadata.supertypeMetadata else {
            return nil
        }
        
        return .init(
            unchecked: subject as Any,
            typeMetadata: supertypeMetadata
        )
    }
    
    init(
        unchecked subject: Any,
        typeMetadata: TypeMetadata.NominalOrTuple
    ) {
        self.subject = subject
        self.typeMetadata = typeMetadata
        
        self._cachedFieldsByName = Dictionary(OrderedDictionary(values: typeMetadata.fields, uniquelyKeyedBy: { AnyCodingKey(stringValue: $0.name) }))
    }
        
    public init?(_ subject: Subject) {
        let _subject = _unwrapExistential(subject)
        
        self.init(
            unchecked: _subject,
            typeMetadata: .of(_subject)
        )
    }
}

// MARK: - Conformances

extension AnyNominalOrTupleMirror: CustomStringConvertible {
    public var description: String {
        String(describing: subject)
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
    
    public var keys: [AnyCodingKey] {
        fields.map({ .init(stringValue: $0.name) })
    }
    
    public var allKeys: [AnyCodingKey] {
        allFields.map({ .init(stringValue: $0.name) })
    }
    
    /// Accesses the value of the given field.
    ///
    /// This is **unsafe**.
    public subscript(field: NominalTypeMetadata.Field) -> Any {
        get {
            return OpaqueExistentialContainer.withUnretainedValue(subject) {
                $0.withUnsafeBytes { bytes in
                    field.type.opaqueExistentialInterface.copyValue(
                        from: bytes.baseAddress?.advanced(by: field.offset)
                    )
                }
            }
        } set {
            assert(type(of: newValue) == field.type.base)

            var _subject: Any = subject
            
            OpaqueExistentialContainer.withUnretainedValue(&_subject) {
                $0.withUnsafeMutableBytes { bytes in
                    field.type.opaqueExistentialInterface.reinitializeValue(
                        at: bytes.baseAddress?.advanced(by: field.offset),
                        to: newValue
                    )
                }
            }
            
            subject = _subject as! Subject
        }
    }
    
    public subscript(_ key: AnyCodingKey) -> Any? {
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
    
    private func fieldForKey(_ key: AnyCodingKey) -> NominalTypeMetadata.Field? {
        _cachedFieldsByName[key] ?? typeMetadata.allFields.first(where: { $0.key == key })
    }
}

extension AnyNominalOrTupleMirror: Sequence {
    public typealias Element = (key: AnyCodingKey, value: Any)
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

public enum _AnyMirrorPathElement: Hashable, Sendable {
    case field(AnyCodingKey)
}

public protocol _AnyMirrorVisitor {
    func shouldVisitChildren<T>(
        of subject: T,
        at path: [_AnyMirrorPathElement]
    ) -> Bool
    
    func visit<T>(
        _ mirror: AnyNominalOrTupleMirror<T>,
        at path: [_AnyMirrorPathElement]
    ) throws
}

extension AnyNominalOrTupleMirror {
    public func _accept(
        visitor: _AnyMirrorVisitor,
        at path: [_AnyMirrorPathElement]
    ) throws {
        guard visitor.shouldVisitChildren(of: subject, at: path) else {
            return
        }
        
        try visitor.visit(self, at: path)
        
        for (field, value) in self {
            guard visitor.shouldVisitChildren(of: value, at: path.appending(.field(field))) else {
                continue
            }
            
            if let mirror = _AnyNominalOrTupleMirror_init(value) {
                try mirror._accept(visitor: visitor, at: path.appending(.field(field)))
            }
        }
    }
}

extension _AnyMirrorVisitor {
    public func visit<T>(_ mirror: AnyNominalOrTupleMirror<T>) throws {
        try mirror._accept(visitor: self, at: [])
    }
}

private func _AnyNominalOrTupleMirror_init(_ x: Any) -> (any _AnyMirrorType)? {
    func makeMirror<T>(_ subject: T) -> (any _AnyMirrorType)? {
        AnyNominalOrTupleMirror(subject)
    }
    
    return _openExistential(x, do: makeMirror)
}

