//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _DeferredAsyncIterator<Iterator: AsyncIteratorProtocol>: AsyncIteratorProtocol {
    public typealias Element = Iterator.Element
    
    private var makeIterator: (() async throws -> Iterator)?
    private var iterator: Iterator?
    
    public init(
        _ makeIterator: @escaping () async throws -> Iterator
    ) where Iterator.Element == Element {
        self.makeIterator = makeIterator
    }
    
    public mutating func next() async throws -> Element? {
        if self.iterator != nil {
            return try await self.iterator?.next()
        } else {
            self.iterator = try await makeIterator.unwrap()()
            self.makeIterator = nil
            
            return try await self.iterator!.next()
        }
    }
}
