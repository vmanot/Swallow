//
// Copyright (c) Vatsal Manot
//

import Swift

extension Collection {
    public var bounds: Range<Index> {
        startIndex..<endIndex
    }
    
    public var lastIndex: Index? {
        guard !isEmpty else {
            return nil
        }
        
        return self.index(atDistance: self.count - 1)
    }
    
    public var second: Element? {
        guard count > 1 else {
            return nil
        }
        
        return self[index(self.startIndex, offsetBy: 1)]
    }
    
    public var last: Element? {
        guard let lastIndex else {
            return nil
        }
        
        return self[lastIndex]
    }
    
    public func containsIndex(_ index: Index) -> Bool {
        index >= startIndex && index < endIndex
    }
    
    public func contains(after index: Index) -> Bool {
        containsIndex(index) && containsIndex(self.index(after: index))
    }
    
    public func contains(_ bounds: Range<Index>) -> Bool {
        containsIndex(bounds.lowerBound) && containsIndex(index(bounds.upperBound, offsetBy: -1))
    }
    
    public func index(atDistance distance: Int) -> Index {
        index(startIndex, offsetBy: distance)
    }
    
    public func index(_ index: Index, insetBy distance: Int) -> Index {
        self.index(index, offsetBy: -distance)
    }
    
    public func index(_ index: Index, offsetByDistanceFromStartIndexFor otherIndex: Index) -> Index {
        self.index(index, offsetBy: distanceFromStartIndex(to: otherIndex))
    }
    
    public func indices(of element: Element) -> [Index] where Element: Equatable {
        indices.filter({ self[$0] == element })
    }
    
    public func index(before index: Index) -> Index where Index: Strideable {
        index.predecessor()
    }
    
    public func index(after index: Index) -> Index where Index: Strideable {
        index.successor()
    }
    
    public func distanceFromStartIndex(to index: Index) -> Int {
        distance(from: startIndex, to: index)
    }
    
    public func _stride() -> Index.Stride where Index: Strideable {
        startIndex.distance(to: endIndex)
    }
    
    public func range(from range: Range<Int>) -> Range<Index> {
        index(atDistance: range.lowerBound)..<index(atDistance: range.upperBound)
    }
}
