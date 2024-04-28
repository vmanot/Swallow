//
// Copyright (c) Vatsal Manot
//

import Swift

extension BidirectionalCollection {
    @inlinable
    public var lastIndex: Index? {
        guard !isEmpty else {
            return nil
        }

        return index(before: endIndex)
    }
    
    @inlinable
    public func index(ifPresentBefore index: Index) -> Index? {
        guard index != startIndex else {
            return nil
        }
        
        return self.index(before: index)
    }
    
    @inlinable
    public func index(ifPresentAfter index: Index) -> Index? {
        guard index != lastIndex else {
            return nil
        }
        
        return self.index(after: index)
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
    public func reverse(index i: Index) -> Index {
        guard let lastIndex else {
            return i
        }
        
        return index(atDistance: distance(from: i, to: lastIndex))
    }
    
    @inlinable
    public subscript(reverse index: Index) -> Element {
        return self[reverse(index: index)]
    }
}

extension BidirectionalCollection where Self: MutableCollection {
    public subscript(reverse index: Index) -> Element {
        get {
            return self[reverse(index: index)]
        } set {
            self[reverse(index: index)] = newValue
        }
    }
    
    @inlinable
    public mutating func reverseInPlace() {
        let indexToBreakLoopAt = index(atDistance: count / 2)
        
        for index in indices.prefix(while: { $0 != indexToBreakLoopAt }) {
            swapAt(index, reverse(index: index))
        }
    }
}

extension BidirectionalCollection {
    public func hasSuffix<Suffix: BidirectionalCollection<(Element) -> Bool>>(
        _ suffix: Suffix
    ) -> Bool {
        guard self.count >= suffix.count else {
            return false
        }

        var subjectIndex = self.endIndex
        var suffixIndex = suffix.endIndex
        
        while subjectIndex > self.startIndex, suffixIndex > suffix.startIndex {
            self.formIndex(before: &subjectIndex)
            suffix.formIndex(before: &suffixIndex)
            
            guard suffix[suffixIndex](self[subjectIndex]) else {
                return false
            }
        }
        
        guard suffixIndex == suffix.startIndex else {
            return false
        }
        
        return true
    }
    
    public func hasSuffix<Suffix: BidirectionalCollection<Element>>(
        _ suffix: Suffix
    ) -> Bool where Element: Equatable {
        return hasSuffix(suffix.lazy.map { element in
            { element == $0 }
        })
    }
}

extension BidirectionalCollection {
    public func unfoldingBackward() -> UnfoldSequence<(SubSequence, Element), SubSequence> {
        sequence(state: prefix(upTo: endIndex)) { (subsequence: inout SubSequence) in
            guard let (head, tail) = subsequence.splittingLast() else {
                return nil
            }
            
            subsequence = head
            
            return (head, tail)
        }
    }
}
