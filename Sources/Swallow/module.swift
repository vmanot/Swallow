//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import _RuntimeC
import Swift

public final class _objc_associated_object_key_generator {
    @inline(never)
    public static func _generate_associated_object_key() -> UnsafeRawPointer {
        return UnsafeRawPointer(_get_associated_object_key()!)
    }
}

public enum _module {
    public static let bundleIdentifier = "com.vmanot.Swallow"
    
    public static func initialize() {
        
    }
}

precedencegroup CompositionPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

precedencegroup ReverseCompositionPrecedence {
    associativity: right
    higherThan: AdditionPrecedence
}
