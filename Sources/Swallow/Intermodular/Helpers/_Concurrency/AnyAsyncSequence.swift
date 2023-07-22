//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased asynchronous sequence.
public struct AnyAsyncSequence<Element>: AsyncSequence, Sendable {
    let _makeAsyncIterator: @Sendable () -> AnyAsyncIterator<Element>
    
    public init<Iterator: AsyncIteratorProtocol>(
        _ makeUnderlyingIterator: @escaping @Sendable () -> Iterator
    ) where Iterator.Element == Element {
        _makeAsyncIterator = { .init(makeUnderlyingIterator()) }
    }
    
    public init<Iterator: IteratorProtocol>(
        _ makeUnderlyingIterator:  @escaping @Sendable () -> Iterator
    ) where Iterator.Element == Element {
        self.init({ AnyAsyncIterator(makeUnderlyingIterator()) })
    }
    
    public init<S: AsyncSequence>(_ sequence: S) where S.Element == Element {
        self.init({ sequence.makeAsyncIterator() })
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init({ sequence.makeIterator() })
    }
    
    public func makeAsyncIterator() -> AnyAsyncIterator<Element> {
        _makeAsyncIterator()
    }
}

// MARK: - Supplementary

extension AsyncSequence {
    public func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element> {
        .init(self)
    }
}

extension Sequence {
    public func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element> {
        .init(self)
    }
}
