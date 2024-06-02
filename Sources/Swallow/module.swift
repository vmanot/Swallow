//
// Copyright (c) Vatsal Manot
//

private import _RuntimeC
import ObjectiveC
import Swift

@available(*, deprecated)
public typealias _module = module

public enum module: _StaticSwift.module {
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

precedencegroup LeftAssociativityFunctionArrowPrecedence {
    associativity: left
    higherThan: FunctionArrowPrecedence
}

infix operator --> : LeftAssociativityFunctionArrowPrecedence

precedencegroup LeftAssociativityConjunctionPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator <--> : LeftAssociativityConjunctionPrecedence
