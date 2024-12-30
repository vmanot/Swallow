//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public enum ArrayIndexPredicateExpression<ArrayExpression: CocoaPredicateExpression>: CocoaPredicateExpression where ArrayExpression.Value: AnyArray {
    public typealias Root = ArrayExpression.Root
    public typealias Value = ArrayExpression.Value.ArrayElement
    
    case index(ArrayExpression, Int)
    case first(ArrayExpression)
    case last(ArrayExpression)
}
