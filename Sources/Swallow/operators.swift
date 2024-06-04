//
// Copyright (c) Vatsal Manot
//

import Swift

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

precedencegroup LeftAssociativityConjunctionPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator --> : LeftAssociativityFunctionArrowPrecedence
infix operator <--> : LeftAssociativityConjunctionPrecedence
