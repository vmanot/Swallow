//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    @frozen
    public struct Existential {
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard _MetadataType(base: base).kind == .existential else {
                return nil
            }
            
            self.base = base
        }
    }
}

extension TypeMetadata.Existential {
    public var mangledName: String {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            TypeMetadata(base).mangledName!
        } else {
            fatalError()
        }
    }
    
    public var isClassConstrained: Bool {
        _metadata.metadata.pointee.flags.isClassConstrained
    }
}

// MARK: - Conformances

@_spi(Internal)
extension TypeMetadata.Existential: _SwiftRuntimeTypeMetadataRepresenting {
    public typealias _MetadataType = _SwiftRuntimeTypeMetadata<_ExistentialMetadataLayout>
}

// MARK: - Internal

/*extension TypeMetadata.Existential {
 public var protocols: [SwiftRuntimeProtocolConformanceDescriptor] {
 Array(unsafeUninitializedCapacity: numProtocols) {
 var start = trailing
 
 if flags.hasSuperclassConstraint {
 start = start.offset(of: 1)
 }
 
 for i in 0 ..< numProtocols {
 let proto = start.load(
 fromByteOffset: i * MemoryLayout<ProtocolDescriptor>.size,
 as: ProtocolDescriptor.self
 )
 
 $0[i] = proto
 }
 
 $1 = numProtocols
 }
 }
 }
 */
extension TypeMetadata {
    @_optimize(speed)
    @_transparent
    public func conforms(
        to testType: Any.Type
    ) -> Bool {
        if base == testType {
            return true
        }
        
        func _conformsToType<A>(
            _ type: A.Type
        ) -> Bool {
            self.base is A.Type
        }
        
        func _conformsToMetatype<A>(
            _ type: A.Type
        ) -> Bool {
            self.base is A
        }
        
        if _openExistential(testType, do: _conformsToType) {
            return true
        }
        
        if let existentialMetatype = _swift_getExistentialMetatypeMetadata(testType) {
            if _openExistential(existentialMetatype, do: _conformsToMetatype) {
                return true
            }
        }
        
        /*guard let protocolType = TypeMetadata.Existential(testType) else {
         return false
         }*/
        
        return false
        
        /*
         let protocolDescriptor = protocolType.metadata.metadata.pointee.protocolDescriptorVector
         
         return _conformsToProtocol(base, protocolDescriptor) != nil*/
    }
        
    public func _conforms(
        toExistentialMetatype testType: Any.Type
    ) -> Bool {
        let base: Any.Type = self.base
        
        
        func _conformsToMetatype<A>(
            _ type: A.Type
        ) -> Bool {
            base is A
        }
        
        let result: Bool = _openExistential(testType, do: _conformsToMetatype)
        
        return result
    }
    
    @_optimize(speed)
    @_transparent
    public func conforms(
        to testType: TypeMetadata
    ) -> Bool {
        conforms(to: testType.base)
    }
}

extension Metatype {
    public func conforms<U>(
        to other: Metatype<U>
    ) -> Bool {
        TypeMetadata(_unwrapBase()).conforms(to: other._unwrapBase())
    }
}

extension TypeMetadata.Existential {
    /// A discriminator to determine the special protocolness of an existential.
    public enum SpecialProtocol: UInt8 {
        /// Every other protocol (not special at all, sorry.)
        case none = 0
        
        /// Swift.Error
        case error = 1
    }
    
    /// The flags that describe some existential metadata.
    public struct Flags {
        /// Flags as represented in bits.
        public let bits: UInt32
        
        /// The number of witness tables that are needed for this existential.
        public var numWitnessTables: Int {
            Int(bits & 0xFFFFFF)
        }
        
        /// The kind of special protocol this is.
        public var specialProtocol: SpecialProtocol {
            SpecialProtocol(rawValue: UInt8((bits & 0x3F000000) >> 24))!
        }
        
        /// Whether this existential has a superclass constraint.
        public var hasSuperclassConstraint: Bool {
            bits & 0x40000000 != 0
        }
        
        /// Whether this existential is class constrained. E.g. AnyObject constraint.
        public var isClassConstrained: Bool {
            // Note this is inverted on purpose
            bits & 0x80000000 == 0
        }
    }
}
