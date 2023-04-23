//
// Copyright (c) Vatsal Manot
//

import Swift

extension NonDestroyingSequence {
    public func around(
        _ predicate: ((Element) throws -> Bool)
    ) rethrows -> AroundElementSequence<SequenceToCollection<Self>.SubSequence, Element, SequenceToCollection<Self>.SubSequence>? {
        try SequenceToCollection(self).around(predicate)
    }
}

extension Collection {
    @inlinable
    public func around(
        _ predicate: ((Element) throws -> Bool)
    ) rethrows -> AroundElementSequence<SubSequence, Element, SubSequence>? {
        guard let (index, element) = try enumerated().find({ try predicate($1) }) else {
            return nil
        }
        
        return .init(left: subsequence(till: index), element: element, right: subsequence(after: index))
    }
}

// MARK: - Helpers

public struct AroundElementSequence<LeftSequence: Sequence, Element, RightSequence: Sequence>: Sequence where LeftSequence.Element == RightSequence.Element, LeftSequence.Element == Element {
    public typealias Element = LeftSequence.Element
    
    public let left: LeftSequence
    public let element: Element
    public let right: RightSequence
    
    public init(left: LeftSequence, element: Element, right: RightSequence) {
        self.left = left
        self.element = element
        self.right = right
    }
    
    public typealias Iterator = Join3Sequence<LeftSequence, CollectionOfOne<Element>, RightSequence>.Iterator
    
    public func makeIterator() -> Iterator {
        return left.join(CollectionOfOne(element)).join(right).makeIterator()
    }
}
