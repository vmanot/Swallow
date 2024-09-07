//
// Copyright (c) Vatsal Manot
//

import Swift

extension TypeMetadata {
    @_transparent
    func _unsafelyReadInstance(
        from pointer: UnsafeRawPointer
    ) -> Any? {
        let value: Any = ProtocolTypeContainer(type: base).accessor._unsafelyReadInstance(from: pointer)
        
        if kind == .optional {
            let mirror = Mirror(reflecting: value)
            
            return mirror.children.first?.value
        }
        
        return value
    }
    
    @_transparent
    func _unsafelySetInstance(
        _ value: Any,
        at pointer: UnsafeMutableRawPointer
    ) {
        ProtocolTypeContainer(type: base).accessor._unsafelySetInstance(value as Any, at: pointer)
    }
}

extension TypeMetadata {
    @frozen
    @usableFromInline
    struct ProtocolTypeContainer {
        @_alwaysEmitConformanceMetadata
        @usableFromInline
        protocol Accessor {
            
        }
        
        let type: Any.Type
        let witnessTable: Int = 0
        
        fileprivate var accessor: TypeMetadata.ProtocolTypeContainer.Accessor.Type {
            unsafeBitCast(self, to: TypeMetadata.ProtocolTypeContainer.Accessor.Type.self)
        }
    }
}

extension TypeMetadata.ProtocolTypeContainer.Accessor {
    @_transparent
    static func _unsafelyReadInstance(
        from pointer: UnsafeRawPointer
    ) -> Any {
        return pointer.assumingMemoryBound(to: Self.self).pointee
    }
    
    @_transparent
    static func _unsafelySetInstance(
        _ value: Any,
        at pointer: UnsafeMutableRawPointer
    ) {
        if let value = value as? Self {
            pointer.assumingMemoryBound(to: self).pointee = value
        } else {
            assertionFailure()
        }
    }
}
