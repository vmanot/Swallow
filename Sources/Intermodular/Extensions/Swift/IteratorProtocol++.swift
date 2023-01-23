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
        _ count: N
    ) -> Element? where N.Stride: SignedInteger {
        var result: Element?
        
        (0..<count).forEach({ _ in result = self.next()! })
        
        return result
    }
    
    @inlinable
    public func exhausting() -> Self {
        return build(self, with: { $0.exhaust() })
    }
}

extension IteratorProtocol {
    @inlinable
    public func makeSequence() -> IteratorSequence<Self> {
        return .init(self)
    }
}
