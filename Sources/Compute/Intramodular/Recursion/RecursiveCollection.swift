//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol RecursiveCollection: RecursiveSequence, Collection {
    associatedtype RecursiveIndex = DefaultRecursiveIndex<Index>
    associatedtype RecursiveIndices: Sequence where RecursiveIndices.Element == RecursiveIndex
    
    var recursiveIndices: RecursiveIndices { get }
    
    func deepestIndex(from _: RecursiveIndex) -> Index
    func recurrableIndex(from _: Index) -> RecursiveIndex
    func parentIndex(of _: RecursiveIndex) -> RecursiveIndex?
    func index(_ index: Index, withChild: Index) -> RecursiveIndex
    func index(_ index: Index, withChildren: RecursiveIndex) -> RecursiveIndex
    
    subscript(_ index: RecursiveIndex) -> Element { get }
}

// MARK: - Extensions

public struct RecursiveAdjacencyMapElement<C: BidirectionalCollection & RecursiveCollection>: CustomStringConvertible {
    private var collection: ReferenceBox<C>
    private var leftIndex: C.RecursiveIndex?
    private var currentIndex: C.RecursiveIndex
    private var rightIndex: C.RecursiveIndex?
    
    public init(
        collection: ReferenceBox<C>,
        leftIndex: C.RecursiveIndex?,
        currentIndex: C.RecursiveIndex,
        rightIndex: C.RecursiveIndex?
    ) {
        self.collection = collection
        self.leftIndex = leftIndex
        self.currentIndex = currentIndex
        self.rightIndex = rightIndex
    }
    
    public init(collection: ReferenceBox<C>, currentIndex: C.RecursiveIndex) {
        let deepest = collection.value.deepestIndex(from: currentIndex)
        let leftIndex = collection.value.index(ifPresentBefore: deepest).map(collection.value.recurrableIndex(from:))
        let rightIndex = collection.value.index(ifPresentAfter: deepest).map(collection.value.recurrableIndex(from:))
        
        self.init(
            collection: collection,
            leftIndex: leftIndex,
            currentIndex: currentIndex,
            rightIndex: rightIndex
        )
    }
    
    public var left: RecursiveAdjacencyMapElement? {
        return leftIndex.map({ .init(collection: collection, currentIndex: $0) })
    }
    
    public var leftValue: C.Element? {
        return leftIndex.map({ collection.value[$0] })
    }
    
    public var value: C.Element {
        return collection.value[currentIndex]
    }
    
    public var right: RecursiveAdjacencyMapElement? {
        return rightIndex.map({ .init(collection: collection, currentIndex: $0) })
    }
    
    public var rightValue: C.Element? {
        return rightIndex.map({ collection.value[$0] })
    }
    
    public var parent: C.Element? {
        return collection.value.parentIndex(of: currentIndex).map({ collection.value[$0] })
    }
    
    public var description: String {
        return String(describing: (leftValue: leftValue, value: value, rightValue: rightValue))
    }
}

extension RecursiveCollection where Self: BidirectionalCollection {
    public func recurrableIndexComparisonMap<T>(
        _ f: ((_ left: RecursiveIndex?, _ current: RecursiveIndex, _ right: RecursiveIndex?) -> T)
    ) -> RecursiveArray<T> {
        var result: RecursiveArray<T> = []
        
        for (index, element) in _enumerated() {
            var left: RecursiveIndex?
            var right: RecursiveIndex?
            
            if index != startIndex {
                left = self.recurrableIndex(from: self.index(before: index))
            }
            
            if index != lastIndex {
                right = self.recurrableIndex(from: self.index(after: index))
            }
            
            if element.isLeft {
                result += f(left, self.recurrableIndex(from: index), right)
            }
            
            else if let rightValue = element.rightValue {
                result += rightValue.recurrableIndexComparisonMap {
                    (left, current, right) in
                    
                    let left = left.map({ self.index(index, withChildren: $0) })
                    let current = self.index(index, withChildren: current)
                    let right = right.map({ self.index(index, withChildren: $0) })
                    
                    return f(left, current, right)
                }
            }
        }
        
        return result
    }
    
    public func recursiveAdjacencyMap() -> RecursiveArray<RecursiveAdjacencyMapElement<Self>> {
        let collection = ReferenceBox(self)
        
        return recurrableIndexComparisonMap({ RecursiveAdjacencyMapElement(collection: collection, leftIndex: $0, currentIndex: $1, rightIndex: $2) })
    }
    
    public func adjacencyMap() -> [RecursiveAdjacencyMapElement<Self>] {
        let collection = ReferenceBox(self)
        
        return recursiveIndices.map({ .init(collection: collection, currentIndex: $0) })
    }
}

extension RecursiveCollection {
    public func recursivelyEnumerated() -> [(RecursiveIndex, Unit)] {
        var result: [(RecursiveIndex, Unit)] = []
        
        for (index, element) in _enumerated() {
            if let unit = element.leftValue {
                result += (recurrableIndex(from: index), unit)
            }
            
            else {
                result.append(contentsOf: element.rightValue!.recursivelyEnumerated().map({ (self.index(index, withChildren: $0.0), $0.1) }))
            }
        }
        
        return result
    }
}

extension RecursiveCollection {
    public subscript<S: Sequence>(recursive indices: S) -> Element where S.Element == Index {
        return indices.reduce(Element(.right(self)), { $0.rightValue![$1] })
    }
}

extension RecursiveCollection where Self: MutableCollection {
    public subscript<S: Collection>(
        recursive indices: S
    ) -> Element where S.Element == Index {
        get {
            return indices.reduce(Element(.right(self)), { $0.rightValue![$1] })
        } set {
            if indices.count == 1 {
                self[indices.first!] = newValue
            }
            
            else {
                var x = self[indices.first!].rightValue!
                
                x[recursive: indices.dropFirst()] = newValue
                
                self[indices.first!] = .init(.right(x))
            }
        }
    }
}

// MARK: - Helpers

public struct DefaultRecursiveIndex<Index> {
    public typealias Value = [Index]
    
    public typealias ArrayLiteralElement = Value.ArrayLiteralElement
    public typealias Element = Value.Element
    public typealias Iterator = Value.Iterator
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

public struct DefaultRecursiveIndices<Index>: Sequence {
    public typealias Value = [DefaultRecursiveIndex<Index>]
    public typealias Element = Value.Element
    public typealias Iterator = Value.Iterator
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func makeIterator() -> Iterator {
        value.makeIterator()
    }
}

extension RecursiveCollection where RecursiveIndices == DefaultRecursiveIndices<Index> {
    public var recursiveIndices: RecursiveIndices {
        RecursiveIndices(indices.map({ self.recurrableIndex(from: $0) }))
    }
    
    public func deepestIndex(from index: RecursiveIndex) -> Index {
        index.value.last!
    }
    
    public func recurrableIndex(from index: Index) -> RecursiveIndex {
        RecursiveIndex([index])
    }
    
    public func parentIndex(of index: RecursiveIndex) -> RecursiveIndex? {
        index.value.count == 1 ? nil : RecursiveIndex(index.value.dropLast())
    }
    
    public func index(_ index: Index, withChild childIndex: Index) -> RecursiveIndex {
        .init([index, childIndex])
    }
    
    public func index(_ index: Index, withChildren children: RecursiveIndex) -> RecursiveIndex {
        .init(children.value.inserting(index))
    }
}

extension RecursiveCollection where RecursiveIndex == DefaultRecursiveIndex<Index> {
    public subscript(_ index: RecursiveIndex) -> Element {
        return self[recursive: index.value]
    }
}

extension RecursiveCollection where Self: MutableCollection, RecursiveIndex == DefaultRecursiveIndex<Index> {
    public subscript(_ index: RecursiveIndex) -> Element {
        get {
            return self[recursive: index.value]
        } set {
            self[recursive: index.value] = newValue
        }
    }
}
