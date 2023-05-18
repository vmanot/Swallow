//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol QueueProtocol {
    associatedtype Element
    
    mutating func enqueue(_: Element)
    mutating func dequeue() -> Element?
}
