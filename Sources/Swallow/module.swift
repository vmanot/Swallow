//
// Copyright (c) Vatsal Manot
//

@_implementationOnly import _RuntimeC

import Swift

public func _associated_object_key() -> UnsafeRawPointer {
    _RuntimeC._associated_object_key()
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
