//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeStructContextDescriptor: SwiftRuntimeContextDescriptorProtocol {
    public typealias FieldTypeAccessor = @convention(c) (UnsafePointer<Int>) -> UnsafePointer<Int>
    
    public var flags: Flags
    public var parent: Int32
    public var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    public var accessFunctionPtr: SwiftRuntimeUnsafeRelativePointer<Int32, UnsafeRawPointer>
    public var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    public var numberOfFields: Int32
    public var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int32>
    public var genericContextHeader: TargetTypeGenericContextDescriptorHeader
}
