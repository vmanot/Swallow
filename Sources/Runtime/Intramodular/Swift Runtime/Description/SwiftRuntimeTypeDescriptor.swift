//
// Copyright (c) Vatsal Manot
//

import Swallow

protocol SwiftRuntimeContextDescriptor {
    associatedtype FieldOffsetVectorOffsetType: FixedWidthInteger
    
    var flags: Int32 { get set }
    var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar> { get set }
    var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor> { get set }
    var numberOfFields: Int32 { get set }
    var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, FieldOffsetVectorOffsetType> { get set }
    var genericContextHeader: TargetTypeGenericContextDescriptorHeader { get set }
}
