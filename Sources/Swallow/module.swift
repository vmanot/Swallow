//
// Copyright (c) Vatsal Manot
//

import Swift

public enum _module {
    public static let bundleIdentifier = "com.vmanot.Swallow"
}

precedencegroup CompositionPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

precedencegroup ReverseCompositionPrecedence {
    associativity: right
    higherThan: AdditionPrecedence
}
