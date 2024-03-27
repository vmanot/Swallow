//
// Copyright (c) Vatsal Manot
//

@_exported import RuntimeC

import Swift

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
