//
// Copyright (c) Vatsal Manot
//

import Swift

extension IteratorProtocol {
    @inlinable
    public mutating func exhaust() {
        while next() != nil {
            // do nothing
        }
    }
    
    @inlinable
    public mutating func exhaust<N: Numeric & Strideable>(
        count: N
    ) -> Element? where N.Stride: SignedInteger {
        var result: Element?
        
        (0..<count).forEach({ _ in result = self.next()! })
        
        return result
    }
    
    @inlinable
    public func exhausting() -> Self {
        build(self, with: { $0.exhaust() })
    }
}

extension AsyncIteratorProtocol {
    @discardableResult
    @inlinable
    public mutating func exhaust() async throws -> [Element] {
        var result: [Element] = []
        
        while let next = try await self.next(){
            result.append(next)
        }
        
        return result
    }
}

extension IteratorProtocol {
    @inlinable
    public func makeSequence() -> IteratorSequence<Self> {
        .init(self)
    }
}

extension IteratorProtocol {
    public func _opaque_eraseToAnyIterator() -> any IteratorProtocol {
        AnyIterator(self)
    }

    public func eraseToAnyIterator() -> AnyIterator<Element> {
        AnyIterator(self)
    }
}

extension AnyIterator {
    public func eraseToAnyIterator() -> Self {
        self
    }
}

extension Sequence {
    public func _opaque_makeAndEraseIterator() -> Any {
        makeIterator()._opaque_eraseToAnyIterator()
    }
}
