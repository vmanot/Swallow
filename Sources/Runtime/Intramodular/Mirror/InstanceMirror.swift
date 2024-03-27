//
// Copyright (c) Vatsal Manot
//

import OrderedCollections
@_spi(Internal) import Swallow

public struct InstanceMirror<Subject>: _InstanceMirrorType, _VisitableMirror, MirrorType {
    private var lock = OSUnfairLock()
    
    public var subject: Any
    public let typeMetadata: TypeMetadata.NominalOrTuple
            
    private init(
        unchecked subject: Any,
        typeMetadata: TypeMetadata.NominalOrTuple
    ) {
        self.subject = subject
        self.typeMetadata = typeMetadata
    }
    
    package var _fixedTypeMetadata: TypeMetadata {
        TypeMetadata(__fixed_type(of: self.subject))
    }
        
    @usableFromInline
    package init?(_subject subject: Any) {
        func _typeMetadataFromValue<T>(_ x: T) -> TypeMetadata.NominalOrTuple? {
            TypeMetadata.NominalOrTuple(type(of: x))
        }
        
        guard let metadata = _openExistential(subject, do: _typeMetadataFromValue) ?? TypeMetadata.NominalOrTuple.of(subject) else {
            assertionFailure()
            
            return nil
        }
        
        self.init(
            unchecked: subject,
            typeMetadata: metadata
        )
    }
    
    @inlinable
    public init?(
        _ subject: Subject
    ) {
        self.init(_subject: subject)
    }
    
    @inlinable
    public init(
        reflecting subject: Subject
    ) throws {
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

public struct _TypedInstanceMirrorElement<T> {
    public let key: AnyCodingKey
    public let value: T
}

extension InstanceMirror {
    public var supertypeMirror: InstanceMirror<Any>? {
        guard let supertypeMetadata = typeMetadata.supertypeMetadata else {
            return nil
        }
        
        return .init(
            unchecked: subject as Any,
            typeMetadata: supertypeMetadata
        )
    }

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
    public subscript(
        field: NominalTypeMetadata.Field
    ) -> Any {
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
            func getValue<T>(from x: T) -> Any {
                var x = x
                
                return swift_value(of: &x, key: key.stringValue)
            }
            
            return _openExistential(subject, do: getValue)
        } set {
            guard let field = fieldForKey(key) else {
                assertionFailure()
                
                return
            }
            
            self[field] = newValue
        }
    }
    
    private func fieldForKey(
        _ key: AnyCodingKey
    ) -> NominalTypeMetadata.Field? {
        if let result = InstanceMirrorCache._cachedFieldsByNameByType[_fixedTypeMetadata]?[key] {
            return result
        }
        
        return typeMetadata.allFields.first(where: { $0.key == key })
    }
}

extension InstanceMirror {
    public typealias _TypedElement<T> = _TypedInstanceMirrorElement<T>
    
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
            
            if value is _InstanceMirrorType {
                fatalError()
            }
            
            guard let valueMirror = InstanceMirror<Any>(value) else {
                continue
            }
            
            try valueMirror.recursiveForEachChild(conformingTo: protocolType, operation)
        }
    }
}

// MARK: - Conformances

extension InstanceMirror: CustomStringConvertible {
    public var description: String {
        String(describing: subject)
    }
}

extension InstanceMirror: Sequence {
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

// MARK: - Internal

public protocol _InstanceMirrorType {
    
}

fileprivate enum InstanceMirrorCache {
    static var lock = OSUnfairLock()
    
    static var _cachedFieldsByNameByType: [TypeMetadata: [AnyCodingKey: NominalTypeMetadata.Field]] = [:]
    
    static func withCriticalRegion<T>(
        _ operation: (Self.Type) -> T
    ) -> T {
        lock.withCriticalScope {
            operation(self)
        }
    }
}

extension InstanceMirror {
    fileprivate func _cacheFields() {
        let type = _fixedTypeMetadata
        
        InstanceMirrorCache.withCriticalRegion {
            guard $0._cachedFieldsByNameByType[type] == nil else {
                return
            }
            var mirror: Mirror!
            
            $0._cachedFieldsByNameByType[type] = Dictionary(
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
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "InstanceMirror")
public typealias AnyNominalOrTupleMirror<Subject> = InstanceMirror<Subject>

extension InstanceMirror {
    @available(*, deprecated, renamed: "subject")
    public var value: Any {
        fatalError()
    }
}
