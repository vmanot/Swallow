//
// Copyright (c) Vatsal Manot
//

import Swift

/// A random access collection view over an arbitrary collection.
public struct FauxRandomAccessCollection<C: Collection> {
    public typealias Value = C

    public var value: Value

    @inlinable
    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Conformances -

extension FauxRandomAccessCollection: RandomAccessCollection2 {
    public typealias Element = Value.Element
    public typealias Index = FauxRandomAccessIndex<Value>
    public typealias Indices = DefaultIndices<FauxRandomAccessCollection>

    @inlinable
    public var startIndex: Index {
        return .init(value, value.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        return .init(value, value.endIndex)
    }

    @inlinable
    public var indices: Indices {
        return undocumented {
            return unsafeBitCast((_elements: self, startIndex: startIndex, endIndex: endIndex))
        }
    }

    public subscript(index: Index) -> Element {
        @inlinable get {
            return value[index.value]
        }
    }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Index.Stride {
        return start.distance(to: end)
    }

    @inlinable
    public func index(after index: Index) -> Index {
        return index.advanced(by: 1)
    }

    @inlinable
    public func index(before index: Index) -> Index {
        return index.advanced(by: -1)
    }
}

extension FauxRandomAccessCollection: Sequence {
    public typealias Iterator = Value.Iterator

    @inlinable
    public func makeIterator() -> Iterator {
        return value.makeIterator()
    }
}

// MARK: - Helpers -

extension Collection {
    public var fauxRandomAccessView: FauxRandomAccessCollection<Self> {
        get {
            return .init(self)
        } set {
            self = newValue.value
        }
    }
}
