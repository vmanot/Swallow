//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeStructContextDescriptor: SwiftRuntimeContextDescriptorProtocol {
    public typealias FieldTypeAccessor = @convention(c) (UnsafePointer<Int>) -> UnsafePointer<Int>
    
    public var base: _swift_TypeContextDescriptor
    public var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    public var numberOfFields: Int32
    public var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int32>
    public var genericContextHeader: TargetTypeGenericContextDescriptorHeader
}
