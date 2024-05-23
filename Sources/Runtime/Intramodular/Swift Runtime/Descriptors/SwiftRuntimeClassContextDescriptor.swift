//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
@frozen
public struct SwiftRuntimeClassContextDescriptor: SwiftRuntimeContextDescriptorProtocol {    
    public var base: _swift_TypeContextDescriptor
    public var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    public var superClass: SwiftRuntimeUnsafeRelativePointer<Int32, Any.Type>
    public var negativeSizeAndBoundsUnion: NegativeSizeAndBoundsUnion
    public var positiveSizeOrExtraFlags: Int32
    public var numImmediateMembers: Int32
    public var numberOfFields: Int32
    public var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int>
    public var genericContextHeader: TargetTypeGenericContextDescriptorHeader
    
    public var genericArgumentOffset: Int {
        if flags.kindSpecificFlags .classHasResilientSuperclass{
            fatalError("unimplemented")
        } else if flags.kindSpecificFlags.classAreImmediateMembersNegative {
            return -Int(negativeSizeAndBoundsUnion.rawValue)
        } else {
            return Int(positiveSizeOrExtraFlags - numImmediateMembers)
        }
    }
}

@_spi(Internal)
extension SwiftRuntimeClassContextDescriptor {
    @frozen
    public struct NegativeSizeAndBoundsUnion {
        public var rawValue: Int32
        
        public var metadataNegativeSizeInWords: Int32 {
            rawValue
        }
    }
}
