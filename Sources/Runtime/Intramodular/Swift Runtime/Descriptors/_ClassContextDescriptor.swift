//
// Copyright (c) Vatsal Manot
//

import Atomics
import Swallow

@_spi(Internal)
@frozen
public struct _ClassContextDescriptorLayout: _SwiftRuntimeContextDescriptorLayoutProtocol {
    public var base: _swift_TypeContextDescriptor
    public var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    public var superClass: SwiftRuntimeUnsafeRelativePointer<Int32, Any.Type>
    public var negativeSizeAndBoundsUnion: NegativeSizeAndBoundsUnion
    public var positiveSizeOrExtraFlags: Int32
    public var numberOfImmediateMembers: Int32
    public var numberOfFields: Int32
    public var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int>
    public var genericContextHeader: TargetTypeGenericContextDescriptorHeader
    
    var resilientBounds: TargetStoredClassMetadataBounds {
        @_transparent
        mutating get {
            negativeSizeAndBoundsUnion
                .resilientMetadataBounds()
                .pointee
                .advanced()
                .pointee
        }
    }

    var genericArgumentOffset: Int {
        mutating get {
            if flags.kindSpecificFlags.classHasResilientSuperclass {
                resilientImmediateMembersOffset
            } else {
                nonResilientImmediateMembersOffset
            }
        }
    }
    
    var nonResilientImmediateMembersOffset: Int {
        assert(!flags.kindSpecificFlags.classHasResilientSuperclass)
        
        if flags.kindSpecificFlags.classAreImmediateMembersNegative {
            return -Int(negativeSizeAndBoundsUnion.rawValue)
        } else {
            return Int(positiveSizeOrExtraFlags - numberOfImmediateMembers)
        }
    }
    
    public var metadataBoundsForSwiftClass: _ClassContextDescriptorLayout.TargetStoredClassMetadataBounds {
        let immediateMemberOffset = MemoryLayout<_ClassMetadataLayout>.size
        let positiveSize: UInt32 = UInt32(MemoryLayout<_ClassMetadataLayout>.size / MemoryLayout<Int>.size)
        // This is the class metadata header size, which is the destructor pointer
        // + the value witness table pointer = 16 bytes.
        // 16 bytes / sizeof(void *) = 2
        let negativeSize: UInt32 = 2
        
        return .init(immediateMembersOffset: immediateMemberOffset, bounds: .init(positiveSizeWords: positiveSize, negativeSizeWords: negativeSize))
    }
}

extension UnsafeMutablePointer where Pointee == _ClassContextDescriptorLayout {
    var resilientSuperclass: UnsafeRawPointer? {
        get {
            guard pointee.flags.kindSpecificFlags.classHasResilientSuperclass else {
                return nil
            }
            
            var offset = 0
            
            if pointee.flags.isGeneric {
                offset += pointee.genericContextHeader.size
            }
            
            return advanced(by: MemoryLayout<Self>.size).rawRepresentation.advanced(by: offset)._swift_relativeDirectAddress(as: Void.self)
        }
    }
}


extension _ClassContextDescriptorLayout {
    var resilientSuperclass: UnsafeRawPointer? {
        mutating get {
            withUnsafeMutablePointer(to: &self) {
                $0.resilientSuperclass
            }
        }
    }
    
    var resilientImmediateMembersOffset: Int {
        mutating get {
            let typeFlags: SwiftRuntimeContextDescriptorFlags.KindSpecificFlags = flags.kindSpecificFlags
            
            assert(typeFlags.classHasResilientSuperclass)
            
            let immediateMembersOffset = resilientBounds.immediateMembersOffset
            
            // If this value is already cached, use it.
            if immediateMembersOffset != 0 {
                return immediateMembersOffset / MemoryLayout<Int>.size
            }
            
            // Otherwise, we're going to need to compute it.
            var immediateMemberOffset = 0
            var positiveSize = 0
            var negativeSize = 0
            
            if let superclass = resilientSuperclass {
                switch typeFlags.resilientSuperclassRefKind {
                    case .indirectTypeDescriptor:
                        let superclassContextDescriptor: UnsafeMutablePointer<_ClassContextDescriptorLayout> = superclass.load(as: _swift_SignedPointer<UnsafeRawPointer>.self).signed.assumingMemoryBound(to: _ClassContextDescriptorLayout.self).mutableRepresentation
                        
                        immediateMemberOffset = superclassContextDescriptor.pointee.genericArgumentOffset
                        
                    case .directTypeDescriptor:
                        let superclassContextDescriptor: UnsafeMutablePointer<_ClassContextDescriptorLayout> = superclass.assumingMemoryBound(to: _ClassContextDescriptorLayout.self).mutableRepresentation

                        immediateMemberOffset = superclassContextDescriptor.pointee.genericArgumentOffset
                        
                    case .directObjCClass:
#if canImport(ObjectiveC)
                        let name = UnsafePointer<CChar>(superclass._rawValue)
                        guard var cls = objc_lookUpClass(name) else {
                            let name = String(cString: name)
                            fatalError("Failed to lookup Objective-C class named: \(name)")
                        }
                        
                        cls = _swift_getInitializedObjCClass(cls)
                        (immediateMemberOffset, positiveSize, negativeSize) =
                        getMetadataBoundsForObjCClass(cls).value
#else
                        break
#endif
                    case .indirectObjCClass:
#if canImport(ObjectiveC)
                        let cls = UnsafePointer<AnyClass>(superclass._rawValue)
                        (immediateMemberOffset, positiveSize, negativeSize) =
                        getMetadataBoundsForObjCClass(cls.pointee).value
#else
                        break
#endif
                }
            } else {
                (immediateMemberOffset, positiveSize, negativeSize) = self.metadataBoundsForSwiftClass.value
            }
            
            if typeFlags.classAreImmediateMembersNegative {
                negativeSize += Int(numberOfImmediateMembers)
                immediateMemberOffset = -negativeSize * MemoryLayout<Int>.size
            } else {
                immediateMemberOffset = positiveSize * MemoryLayout<Int>.size
                positiveSize += Int(numberOfImmediateMembers)
            }
            
            let startAddress: UnsafeRawPointer = _unsafeSelfRelativeAddress(for: \.negativeSizeAndBoundsUnion)
            let bounds = UnsafeMutablePointer(mutating: startAddress._swift_relativeDirectAddress(
                as: _ClassContextDescriptorLayout.TargetStoredClassMetadataBounds.self
            ).assumingMemoryBound(to: _ClassContextDescriptorLayout.TargetStoredClassMetadataBounds.self))
            
            bounds.pointee.bounds.positiveSizeWords = UInt32(positiveSize)
            bounds.pointee.bounds.negativeSizeWords = UInt32(negativeSize)
            
            bounds.withMemoryRebound(to: Int.AtomicRepresentation.self, capacity: 1) {
                Int.AtomicRepresentation.atomicStore(
                    immediateMemberOffset,
                    at: $0,
                    ordering: .releasing
                )
            }
            
            return immediateMemberOffset / MemoryLayout<Int>.size
        }
    }
}

@_spi(Internal)
extension _ClassContextDescriptorLayout {
    @frozen
    public struct TargetMetadataBounds {
        public var positiveSizeWords: UInt32
        public var negativeSizeWords: UInt32
    }
    
    @frozen
    public struct TargetStoredClassMetadataBounds {
        public var immediateMembersOffset: Int
        public var bounds: TargetMetadataBounds
        
        // 0 = Immediate members offset, 1 = positive size, 2 = negative size
        public var value: (immediateMemberOffset: Int, positiveSize: Int, negativeSize: Int) {
            (immediateMembersOffset, Int(bounds.positiveSizeWords), Int(bounds.negativeSizeWords))
        }
    }
    
    @frozen
    public struct NegativeSizeAndBoundsUnion: _CPlusPlusUnion {
        public var rawValue: Int32
        
        public var metadataNegativeSizeInWords: Int32 {
            rawValue
        }
        
        public mutating func resilientMetadataBounds() -> UnsafeMutablePointer<SwiftRuntimeUnsafeRelativePointer<Int32, TargetStoredClassMetadataBounds>> {
            return bind()
        }
    }
}

private func getMetadataBoundsForObjCClass(_ cls: AnyClass) -> _ClassContextDescriptorLayout.TargetStoredClassMetadataBounds {
    let metadataWrapper: _SwiftRuntimeTypeMetadata<_ClassMetadataLayout> = _reflectRuntimeClassMetadata(ofType: cls)!
    let metadata: _ClassMetadataLayout = metadataWrapper.metadata.pointee
    
    let rootBounds = metadata.contextDescriptor.pointee.metadataBoundsForSwiftClass
    // 0 = Immediate member offset, 1 = positive size, 2 = negative size
    var bounds: (UInt32, UInt32, UInt32) = (0, 0, 0)
    
    if !metadataWrapper.isGeneric {
        return rootBounds
    }
    
    bounds.0 = metadata.classObjectSize - metadata.classObjectAddressPoint
    bounds.1 = (metadata.classObjectSize - metadata.classObjectAddressPoint) / UInt32(MemoryLayout<Int>.size)
    bounds.2 = metadata.classObjectAddressPoint / UInt32(MemoryLayout<Int>.size)
    
    if bounds.2 < rootBounds.bounds.negativeSizeWords {
        bounds.2 = rootBounds.bounds.negativeSizeWords
    }
    
    if bounds.1 < rootBounds.bounds.positiveSizeWords {
        bounds.1 = rootBounds.bounds.positiveSizeWords
    }
    
    return .init(
        immediateMembersOffset: Int(bounds.0),
        bounds: .init(positiveSizeWords: bounds.1, negativeSizeWords: bounds.2)
    )
}
