//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyAsyncSequence<Element>: AsyncSequence {
    let _makeAsyncIterator: () -> AnyAsyncIterator<Element>
    
    public init<Iterator: AsyncIteratorProtocol>(
        _ makeUnderlyingIterator: @escaping () -> Iterator
    ) where Iterator.Element == Element {
        _makeAsyncIterator = { .init(makeUnderlyingIterator()) }
    }
    
    public init<Iterator: IteratorProtocol>(
        _ makeUnderlyingIterator:  @escaping () -> Iterator
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
