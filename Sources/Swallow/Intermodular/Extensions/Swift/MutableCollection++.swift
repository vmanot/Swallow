//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Swift

extension MutableCollection {
    public subscript(atDistance distance: Int) -> Element {
        @inlinable get {
            return self[index(atDistance: distance)]
        } @inlinable set {
            self[index(atDistance: distance)] = newValue
        }
    }
}

extension MutableCollection {
    public mutating func reindexWith<S: Sequence>(_ sequence: S) where S.Element == Element {
        var iterator = sequence.makeIterator()
        
        for index in indices {
            self[index] = iterator.next()!
        }
    }
    
    public mutating func reindexWith<S: Sequence>(_ sequence: S, count: Int) where S.Element == Element {
        var iterator = sequence.makeIterator()
        
        for indexDistance in (0..<count) {
            self[atDistance: indexDistance] = iterator.next()!
        }
    }
    
    public mutating func reindexWith<C: Collection>(_ collection: C, count: Int) where C.Element == Element {
        for indexDistance in (0..<count) {
            self[atDistance: indexDistance] = self[atDistance: indexDistance]
        }
    }
    
    public mutating func reindexWith<C: Collection>(_ collection: C) where C.Element == Element {
        reindexWith(collection, count: count)
    }
}

extension MutableCollection {
    public subscript(try index: Index) -> Element? {
        get {
            return lazy.map({ $0 })[try: index]
        } set {
            if let newValue = newValue, indices.contains(index) {
                self[index] = newValue
            } else {
                fatalError()
            }
        }
    }
    
    public subscript(try bounds: Range<Index>) -> SubSequence? {
        get {
            guard contains(bounds) else {
                return nil
            }
            
            return self[bounds]
        } set {
            if let newValue = newValue, contains(bounds) {
                self[bounds] = newValue
            } else {
                fatalError()
            }
        }
    }
}

extension MutableCollection where Self: RangeReplaceableCollection {
    public subscript(try index: Index) -> Element? {
        get {
            return lazy.map({ $0 })[try: index]
        } set {
            if let newValue = newValue, indices.contains(index) {
                self[index] = newValue
            } else {
                if containsIndex(index) {
                    remove(at: index)
                }
            }
        }
    }
    
    public subscript(try bounds: Range<Index>) -> SubSequence? {
        get {
            guard contains(bounds) else {
                return nil
            }
            
            return self[bounds]
        } set {
            if let newValue = newValue, contains(bounds) {
                self[bounds] = newValue
            } else {
                if contains(bounds) {
                    removeSubrange(bounds)
                }
            }
        }
    }
}

extension MutableCollection {
    public subscript(cycling index: Index) -> Element {
        get {
            return self[cycle(index: index)]
        } set {
            self[cycle(index: index)] = newValue
        }
    }
}
