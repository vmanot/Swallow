//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
@frozen
public struct _ClassMetadataLayout: _ContextualSwiftRuntimeTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var isaPointer: Int
    public var superclass: AnyClass?
    public var objCRuntimeReserve1: Int
    public var objCRuntimeReserve2: Int
    public var rodataPointer: UnsafeRawPointer
    /// Swift-specific class flags.
    public var classFlags: Int32
    /// The address point of instances of this type.
    public var instanceAddressPoint: UInt32
    /// The required size of instances of this type.
    /// 'InstanceAddressPoint' bytes go before the address point;
    /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
    public var instanceSize: UInt32
    /// The alignment mask of the address point of instances of this type.
    public var instanceAlignmentMask: UInt16
    /// Reserved for runtime use.
    public var runtimeReserveField: UInt16
    /// The total size of the class object, including prefix and suffix extents.
    public var classObjectSize: UInt32
    /// The offset of the address point within the class object.
    public var classObjectAddressPoint: UInt32
    /// An out-of-line Swift-specific description of the type, or null
    /// if this is an artificial subclass.  We currently provide no
    /// supported mechanism for making a non-artificial subclass
    /// dynamically.
    public var contextDescriptor: UnsafeMutablePointer<_ClassContextDescriptorLayout>
    /// A function for destroying instance variables, used to clean up after an early return from a constructor.
    public var ivarDestroyer: UnsafeRawPointer?
    
    public var kind: Int {
        isaPointer
    }
    
    public var genericArgumentOffset: Int {
        self.contextDescriptor.pointee.genericArgumentOffset
    }
}

extension _ClassMetadataLayout {
    public var isSwiftClass: Bool {
#if canImport(Darwin)
        // Xcode uses this and older runtimes do too
        var mask = 0x1
        
        // Swift in the OS uses 0x2
        if #available(macOS 10.14.4, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            mask = 0x2
        }
#else
        let mask = 0x1
#endif
        
        return Int(bitPattern: rodataPointer) & mask != 0
    }
    
    public var numberOfImmediateMembers: Int {
        Int(contextDescriptor.pointee.numberOfImmediateMembers)
    }
    
    public var negativeSizeOrResilientBounds: _ClassContextDescriptorLayout.NegativeSizeAndBoundsUnion {
        contextDescriptor.pointee.negativeSizeAndBoundsUnion
    }
}

extension _SwiftRuntimeTypeMetadata where MetadataLayout == _ClassMetadataLayout {
    public var isSwiftClass: Bool {
        metadata.pointee.isSwiftClass
    }
    
    public var numberOfImmediateMembers: Int {
        metadata.pointee.numberOfImmediateMembers
    }
    
    public var negativeSizeOrResilientBounds: _ClassContextDescriptorLayout.NegativeSizeAndBoundsUnion {
        metadata.pointee.negativeSizeOrResilientBounds
    }
}

extension _SwiftRuntimeTypeMetadata where MetadataLayout == _ClassMetadataLayout {
    func superclass() -> AnyClass? {
        guard let superclass = metadata.pointee.superclass else {
            return nil
        }
        
        if superclass != getSwiftObjectBaseSuperclass() && superclass != NSObject.self {
            return superclass
        } else {
            return nil
        }
    }
}

// MARK: - Auxiliary

private func getSwiftObjectBaseSuperclass() -> AnyClass {
    class Temp { }
    
    return class_getSuperclass(Temp.self)!
}

/// - Returns: `ClassMetadata` for the given metatype.
func _reflectRuntimeClassMetadata(
    ofType type: Any.Type
) -> _SwiftRuntimeTypeMetadata<_ClassMetadataLayout>? {
    struct _ObjCClassWrapperMetadataLayout {
        let _kind: Int
        let _classMetadata: Any.Type
    }

    let typePointer = unsafeBitCast(type, to: UnsafeRawPointer.self)
    let kind =  TypeMetadata(type).kind
    
    guard kind == .class || kind == .objCClassWrapper else {
        return nil
    }
    
    if kind == .class {
        return _SwiftRuntimeTypeMetadata<_ClassMetadataLayout>(base: type)
    } else {
        return _reflectRuntimeClassMetadata(ofType: typePointer.load(as: _ObjCClassWrapperMetadataLayout.self)._classMetadata)
    }
}

/// The main entry point to grab a `class`'s metadata from some instance.
/// - Parameter instance: Any instance value of a `class` to get metadata from.
/// - Returns: `ClassMetadata` for the given instance.
func _reflectRuntimeClassMetadata(
    ofTypeOfInstance instance: Any
) -> _SwiftRuntimeTypeMetadata<_ClassMetadataLayout>? {
    let container = OpaqueExistentialContainer.passUnretained(instance)
    
    return _reflectRuntimeClassMetadata(ofType: container.type.base)
}
