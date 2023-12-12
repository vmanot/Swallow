//
// Copyright (c) Vatsal Manot
//

import Swift

@frozen
@usableFromInline
struct SwiftRuntimeClassContextDescriptor: SwiftRuntimeContextDescriptor {
    @usableFromInline
    var flags: Flags
    @usableFromInline
    var parent: Int32
    @usableFromInline
    var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    var fieldTypesAccessor: SwiftRuntimeUnsafeRelativePointer<Int32, Int>
    @usableFromInline
    var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    var superClass: SwiftRuntimeUnsafeRelativePointer<Int32, Any.Type>
    var negativeSizeAndBoundsUnion: NegativeSizeAndBoundsUnion
    var metadataPositiveSizeInWords: Int32
    var numImmediateMembers: Int32
    @usableFromInline
    var numberOfFields: Int32
    @usableFromInline
    var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int>
    @usableFromInline
    var genericContextHeader: TargetTypeGenericContextDescriptorHeader
}

extension SwiftRuntimeClassContextDescriptor {
    @frozen
    @usableFromInline
    struct NegativeSizeAndBoundsUnion {
        @usableFromInline
        var rawValue: Int32
        
        @usableFromInline
        var metadataNegativeSizeInWords: Int32 {
            return rawValue
        }
    }
}
