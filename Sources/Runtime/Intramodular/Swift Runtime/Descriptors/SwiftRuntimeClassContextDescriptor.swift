//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
@frozen
public struct SwiftRuntimeClassContextDescriptor: SwiftRuntimeContextDescriptorProtocol {
    public var flags: Flags
    public var parent: Int32
    public var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    public var fieldTypesAccessor: SwiftRuntimeUnsafeRelativePointer<Int32, Int>
    public var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    public var superClass: SwiftRuntimeUnsafeRelativePointer<Int32, Any.Type>
    public var negativeSizeAndBoundsUnion: NegativeSizeAndBoundsUnion
    public var metadataPositiveSizeInWords: Int32
    public var numImmediateMembers: Int32
    public var numberOfFields: Int32
    public var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int>
    public var genericContextHeader: TargetTypeGenericContextDescriptorHeader
}

@_spi(Internal)
extension SwiftRuntimeClassContextDescriptor {
    @frozen
    public struct NegativeSizeAndBoundsUnion {
        public var rawValue: Int32
        
        public var metadataNegativeSizeInWords: Int32 {
            return rawValue
        }
    }
}
