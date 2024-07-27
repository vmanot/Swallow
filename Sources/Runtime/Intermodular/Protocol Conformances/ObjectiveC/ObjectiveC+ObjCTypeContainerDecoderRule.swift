//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCTypeContainerDecoderRuleForNoRule: ObjCTypeContainerDecoderRule {
    public static let prefix = ""
    public static let suffix = ""
    
    public static func process(_ types: [Any.Type]) throws -> Any.Type {
        try TypeMetadata(tupleWithTypes: types).base
    }
}

public struct ObjCTypeContainerDecoderRuleForArray: ObjCTypeContainerDecoderRule {
    public static let prefix = "["
    public static let suffix = "]"
    
    public static func process(_ types: [Any.Type]) throws -> Any.Type {
        try TypeMetadata(tupleWithTypes: types).base
    }
}

public struct ObjCTypeContainerDecoderRuleForConstantPointer: ObjCTypeContainerDecoderRule {
    public static let prefix = "r^"
    public static let suffix = ""
    
    public static func process(_ types: [Any.Type]) throws -> Any.Type {
        try _extendMetatype(TypeMetadata(tupleWithTypes: types).base).UnsafePointer_Self()
    }
}

public struct ObjCTypeContainerDecoderRuleForPointer: ObjCTypeContainerDecoderRule {
    public static let prefix = "^"
    public static let suffix = ""
    
    public static func process(_ types: [Any.Type]) throws -> Any.Type {
        try _extendMetatype(TypeMetadata(tupleWithTypes: types).base).UnsafeMutablePointer_Self()
    }
}

public struct ObjCTypeContainerDecoderRuleForStructure: ObjCTypeContainerDecoderRule {
    public static let prefix = "{"
    public static let suffix = "}"
    
    public static func process(_ types: [Any.Type]) throws -> Any.Type {
        try TypeMetadata(tupleWithTypes: types).base
    }
}

public struct ObjCTypeContainerDecoderRuleForUnion: ObjCTypeContainerDecoderRule {
    public static let prefix = "("
    public static let suffix = ")"
    
    public static func process(_ types: [Any.Type]) throws -> Any.Type {
        try (types.lazy.map({ TypeMetadata($0) }).sorted(by: { $0.memoryLayout.stride < $1.memoryLayout.stride }).last ?? TypeMetadata(Void.self)).byteTupleRepresentation.base
    }
}
