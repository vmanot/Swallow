//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Peekable {
    associatedtype PeekResult
    
    func peek() -> PeekResult
}

public protocol Poppable: Peekable {
    associatedtype PopResult
    
    mutating func pop() -> PopResult
}
