//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Stack: Poppable where PeekResult == Element, PopResult == Element {
    associatedtype Element
    associatedtype PushResult
    
    mutating func push(_: Element) -> PushResult
}
