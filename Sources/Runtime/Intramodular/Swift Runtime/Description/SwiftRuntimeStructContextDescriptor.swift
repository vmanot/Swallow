//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeStructContextDescriptor: SwiftRuntimeContextDescriptor {
    typealias FieldTypeAccessor = @convention(c) (UnsafePointer<Int>) -> UnsafePointer<Int>
    
    var flags: Int32
    var parent: Int32
    var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    var accessFunctionPtr: SwiftRuntimeUnsafeRelativePointer<Int32, UnsafeRawPointer>
    var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor>
    var numberOfFields: Int32
    var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, Int32>
    var genericContextHeader: TargetTypeGenericContextDescriptorHeader
}
