//
// Copyright (c) Vatsal Manot
//

import Swift

extension BidirectionalCollection {
    @inlinable
    public var lastIndex: Index {
        return index(before: endIndex)
    }
    
    @inlinable
    public func index(ifPresentBefore index: Index) -> Index? {
        return index != startIndex &&-> self.index(before: index)
    }
    
    @inlinable
    public func index(ifPresentAfter index: Index) -> Index? {
        return index != lastIndex &&-> self.index(after: index)
    }
}

extension BidirectionalCollection {
    @inlinable
    public func splittingLast() -> (head: SubSequence, tail: Element)? {
        guard let tail = last else {
            return nil
        }
        
        return (head: prefix(upTo: index(before: endIndex)), tail: tail)
    }
}

extension BidirectionalCollection {
    @inlinable
    public var reverseView: ReversedCollection<Self> {
        return reversed()
    }
    
    @inlinable
    public func reverse(index i: Index) -> Index {
        return index(atDistance: distance(from: i, to: lastIndex))
    }
    
    @inlinable
    public subscript(reverse index: Index) -> Element {
        return self[reverse(index: index)]
    }
}

extension BidirectionalCollection where Self: MutableCollection {
    @inlinable
    public var reverseView: ReversedCollection<Self> {
        get {
            return reversed()
        } set {
            self = newValue._base
        }
    }
    
    public subscript(reverse index: Index) -> Element {
        get {
            return self[reverse(index: index)]
        } set {
            self[reverse(index: index)] = newValue
        }
    }
    
    @inlinable
    public mutating func reverseInPlace() {
        let indexToBreakLoopAt = index(atDistance: length / 2)
        
        for index in indices.prefix(till: indexToBreakLoopAt) {
            swapAt(index, reverse(index: index))
        }
    }
    
    @inlinable
    public func reversed() -> Self {
        return build(self, with: { $0.reverseInPlace() })
    }
}

extension BidirectionalCollection where Element: Equatable {
    @inlinable
    public func ends<Suffix: BidirectionalCollection>(with suffix: Suffix) -> Bool where Suffix.Element == Element {
        guard count >= suffix.count else {
            return false
        }
        
        return suffix
            .reversed()
            .zip(reversed())
            .contains(where: { $0.0 == $0.1 })
    }
}

extension BidirectionalCollection where SubSequence: BidirectionalCollection {
    public func unfoldBackwards() -> UnfoldSequence<(SubSequence, Element), SubSequence> {
        sequence(state: prefix(upTo: endIndex)) { (subsequence: inout SubSequence) in
            guard let (head, tail) = subsequence.splittingLast() else {
                return nil
            }
            
            subsequence = head
            
            return (head, tail)
        }
    }
}
