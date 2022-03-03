//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyAsyncIterator<Element>: AsyncIteratorProtocol {
    let _next: () async throws -> Element?
    
    public init<Iterator: AsyncIteratorProtocol>(_ iterator: Iterator) where Iterator.Element == Element {
        var iterator = iterator
        
        _next = { try await iterator.next() }
    }
    
    public init<Iterator: IteratorProtocol>(_ iterator: Iterator) where Iterator.Element == Element {
        var iterator = iterator
        
        _next = { iterator.next() }
    }
    
    public mutating func next() async throws -> Element? {
        try await _next()
    }
    
}
