//
// Copyright (c) Vatsal Manot
//

import Swift

public struct DistanceIndexedCollection<C: Collection>: Wrapper {
    public typealias Value = C
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Conformances

extension DistanceIndexedCollection: Sequence {
    public typealias Element = Iterator.Element
    public typealias Iterator = Value.Iterator
    public typealias SubSequence = DistanceIndexedCollection<Value.SubSequence>
    
    public func makeIterator() -> Iterator {
        return value.makeIterator()
    }
}

extension DistanceIndexedCollection: Collection {
    public var startIndex: Int {
        value.distanceFromStartIndex(to: value.startIndex)
    }
    
    public var endIndex: Int {
        value.distanceFromStartIndex(to: value.endIndex)
    }
    
    public subscript(_ index: Int) -> Element {
        value[value.index(atDistance: index)]
    }
    
    public subscript(_ bounds: Range<Index>) -> SubSequence {
        .init(value[value.index(atDistance: bounds.lowerBound)..<value.index(atDistance: bounds.upperBound)])
    }
}

// MARK: - Conditional Conformances

extension DistanceIndexedCollection: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        value.description
    }
}
