//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeStructContextDescriptor: SwiftRuntimeContextDescriptorProtocol {
    typealias FieldTypeAccessor = @convention(c) (UnsafePointer<Int>) -> UnsafePointer<Int>
    
    var flags: Flags
    var parent: Int32
    var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    var accessFunctionPtr: SwiftRuntimeUnsafeRelativePointer<Int32, UnsafeRawPointer>
    var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    var numberOfFields: Int32
    var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int32>
    var genericContextHeader: TargetTypeGenericContextDescriptorHeader
}
