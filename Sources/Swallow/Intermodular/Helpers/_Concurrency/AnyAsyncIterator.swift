//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased asynchronous iterator of `Element`.
public struct AnyAsyncIterator<Element>: AsyncIteratorProtocol {
    let _next: () async throws -> Element?
    
    public init<Iterator: AsyncIteratorProtocol>(
        _ iterator: Iterator
    ) where Iterator.Element == Element {
        var iterator = iterator
        
        _next = { try await iterator.next() }
    }
    
    public init<Iterator: IteratorProtocol>(
        _ iterator: Iterator
    ) where Iterator.Element == Element {
        var iterator = iterator
        
        _next = { iterator.next() }
    }
    
    public init<Iterator: AsyncIteratorProtocol>(
        _ makeIterator: @escaping () async throws -> Iterator
    ) where Iterator.Element == Element {
        let makeIteratorAndIterator = ActorIsolated<(makeIterator: (() async throws -> Iterator)?, iterator: Iterator?)>((makeIterator, nil))
        
        _next = {
            let next: Element? = try await makeIteratorAndIterator.withCriticalRegion { (makeIteratorAndIterator) in
                if makeIteratorAndIterator.iterator == nil {
                    makeIteratorAndIterator.iterator = try await makeIteratorAndIterator.makeIterator!()
                    
                    makeIteratorAndIterator.makeIterator = nil
                }
                
                return try await makeIteratorAndIterator.iterator!.next()
            }
            
            return next
        }
    }
    
    public mutating func next() async throws -> Element? {
        try await _next()
    }
}

extension AsyncIteratorProtocol {
    public func eraseToAnyAsyncIterator() -> AnyAsyncIterator<Element> {
        .init(self)
    }
}

extension AnyAsyncIterator {
    @_disfavoredOverload
    @inlinable
    public func filter(
        _ isIncluded: @escaping @Sendable (Element) async -> Bool
    ) -> AnyAsyncIterator {
        AnyAsyncSequence({ self })
            .filter(isIncluded)
            .makeAsyncIterator()
            .eraseToAnyAsyncIterator()
    }
}
