//
// Copyright (c) Vatsal Manot
//

import OrderedCollections
import Swallow

public protocol _VisitableMirror<Subject> {
    associatedtype Subject
    
    func _accept(
        visitor: some _MirrorVisitor,
        at path: [_AnyMirrorPathElement]
    ) throws
}

public protocol _AnyNominalOrTupleMirror_Type {
    
}

public struct AnyNominalOrTupleMirror<Subject>: _AnyNominalOrTupleMirror_Type, _VisitableMirror, MirrorType {
    public var subject: Any
    public let typeMetadata: TypeMetadata.NominalOrTuple
    
    private let _cachedFieldsByName: [AnyCodingKey: NominalTypeMetadata.Field]
    
    @available(*, deprecated, renamed: "subject")
    public var value: Any {
        fatalError()
    }
    
    public var supertypeMirror: AnyNominalOrTupleMirror<Any>? {
        guard let supertypeMetadata = typeMetadata.supertypeMetadata else {
            return nil
        }
        
        return .init(
            unchecked: subject as Any,
            typeMetadata: supertypeMetadata
        )
    }
    
    private init(
        unchecked subject: Any,
        typeMetadata: TypeMetadata.NominalOrTuple
    ) {
        self.subject = subject
        self.typeMetadata = typeMetadata
        
        var mirror: Mirror!
        
        self._cachedFieldsByName = Dictionary(
            OrderedDictionary(
                typeMetadata.fields.map { field in
                    if field.type._isInvalid {
                        mirror = mirror ?? Mirror(reflecting: subject)
                        
                        guard let element = mirror.children.first(where: { $0.label == field.name }) else {
                            assertionFailure()
                            
                            return field
                        }
                        
                        return .init(
                            name: field.name,
                            type: TypeMetadata(Swift.type(of: element.value)),
                            offset: field.offset
                        )
                    } else {
                        return field
                    }
                }.map({ (AnyCodingKey(stringValue: $0.name), $0) }),
                uniquingKeysWith: { lhs, rhs in lhs }
            )
        )
    }
    
    @usableFromInline
    init?(_subject subject: Any) {
        func _typeMetadataFromValue<T>(_ x: T) -> TypeMetadata.NominalOrTuple? {
            TypeMetadata.NominalOrTuple(type(of: x))
        }
        
        guard let metadata = _openExistential(subject, do: _typeMetadataFromValue) ?? TypeMetadata.NominalOrTuple.of(subject) else {
            return nil
        }
        
        self.init(
            unchecked: subject,
            typeMetadata: metadata
        )
    }
    
    @inlinable
    public init?(_ subject: Subject) {
        self.init(_subject: __fixed_opaqueExistential(subject))
    }
    
    @inlinable
    public init(reflecting subject: Subject) throws {
        do {
            self = try Self(_subject: __fixed_opaqueExistential(subject)).unwrap()
        } catch {
            do {
                self = try Self(_subject: subject).unwrap()
            } catch(_) {
                runtimeIssue("Failed to reflect subject of type: \(type(of: _unwrapPossiblyOptionalAny(subject)))")
                
                throw error
            }
        }
    }
}

public struct _TypedAnyNominalOrTupleMirrorElement<T> {
    public let key: AnyCodingKey
    public let value: T
}

extension AnyNominalOrTupleMirror {
    public typealias _TypedElement<T> = _TypedAnyNominalOrTupleMirrorElement<T>
    
    public func forEachChild<T>(
        conformingTo protocolType: T.Type,
        _ operation: (_TypedElement<T>) throws -> Void,
        ingoring: (_TypedElement<Any>) -> Void
    ) rethrows {
        for (key, value) in self.allChildren {
            if TypeMetadata.of(value).conforms(to: protocolType) {
                let element = _TypedElement<T>(
                    key: key,
                    value: value as! T
                )
                
                try operation(element)
            } else {
                ingoring(_TypedElement<Any>(key: key, value: value))
            }
        }
    }
    
    public func recursiveForEachChild<T>(
        conformingTo protocolType: T.Type,
        _ operation: (_TypedElement<T>) throws -> Void
    ) rethrows {
        for (key, value) in self.allChildren {
            if TypeMetadata.of(value).conforms(to: protocolType) {
                let element = _TypedElement(key: key, value: value as! T)
                
                try operation(element)
            }
            
            if value is _AnyNominalOrTupleMirror_Type {
                fatalError()
            }
            
            guard let valueMirror = AnyNominalOrTupleMirror<Any>(value) else {
                continue
            }
            
            try valueMirror.recursiveForEachChild(conformingTo: protocolType, operation)
        }
    }
}

// MARK: - Conformances

extension AnyNominalOrTupleMirror: CustomStringConvertible {
    public var description: String {
        String(describing: subject)
    }
}

extension AnyNominalOrTupleMirror {
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
            if fields.count == 1, fields.first!.type.kind == .existential, typeMetadata.memoryLayout.size == MemoryLayout<Any>.size {
                let mirror = Mirror(reflecting: subject)
                
                assert(mirror.children.count == 1)
                
                let child = mirror.children.first!
                
                assert(child.label == field.key.stringValue)
                
                return child.value
            }
            
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
    
    public subscript(_ key: AnyCodingKey) -> Any {
        get {
            var subject = self.subject
            
            return swift_value(of: &subject, key: key.stringValue)
        } set {
            guard let field = fieldForKey(key) else {
                assertionFailure()
                
                return
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
        keys.map({ ($0, self[$0]) }).makeIterator().eraseToAnyIterator()
    }
}

public enum _AnyMirrorPathElement: Hashable, Sendable {
    case field(AnyCodingKey)
}

public protocol _MirrorVisitor {
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
        visitor: some _MirrorVisitor,
        at path: [_AnyMirrorPathElement]
    ) throws {
        guard visitor.shouldVisitChildren(of: subject, at: path) else {
            return
        }
        
        try visitor.visit(self, at: path)
                
        for (field, childValue) in self {
            let fieldPath = path.appending(.field(field))
            
            guard visitor.shouldVisitChildren(of: childValue, at: fieldPath) else {
                continue
            }
            
            if let childMirror = _AnyNominalOrTupleMirror_init(childValue) {
                try childMirror._accept(visitor: visitor, at: fieldPath)
            }
        }
    }
}

extension _MirrorVisitor {
    public func visit<T>(_ mirror: AnyNominalOrTupleMirror<T>) throws {
        try mirror._accept(visitor: self, at: [])
    }
}

private func _AnyNominalOrTupleMirror_init(_ x: Any) -> (any _VisitableMirror)? {
    func makeMirror<T>(_ subject: T) -> (any _VisitableMirror)? {
        AnyNominalOrTupleMirror(subject)
    }
    
    return _openExistential(x, do: makeMirror)
}

