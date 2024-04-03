//
// Copyright (c) Vatsal Manot
//

@_implementationOnly import RuntimeC

import Swift

public func _associated_object_key() -> UnsafeRawPointer {
    RuntimeC._associated_object_key()
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
