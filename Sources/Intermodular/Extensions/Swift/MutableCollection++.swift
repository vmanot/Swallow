//
// Copyright (c) Vatsal Manot
//

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

extension MutableCollection  {
    @inlinable
    public var mutableFirst: Element? {
        get {
            return isEmpty ? nil : self[startIndex]
        } set {
            if !isEmpty {
                self[startIndex] = newValue!
            }
        }
    }
    
    public var mutableLast: Element? {
        get {
            return isEmpty ||> self[lastIndex]
        } set {
            if !isEmpty {
                self[lastIndex] = newValue!
            }
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
            return Optional(self[bounds], if: contains(bounds))
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
                tryRemove(at: index)
            }
        }
    }
    
    public subscript(try bounds: Range<Index>) -> SubSequence? {
        get {
            return Optional(self[bounds], if: contains(bounds))
        } set {
            if let newValue = newValue, contains(bounds) {
                self[bounds] = newValue
            } else {
                tryRemoveSubrange(bounds)
            }
        }
    }
}

extension MutableCollection {
    public subscript(cyclic index: Index) -> Element {
        get {
            return self[cyclical(index: index)]
        } set {
            self[cyclical(index: index)] = newValue
        }
    }
}
