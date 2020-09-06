//
// Copyright (c) Vatsal Manot
//

import Swift

public struct FauxRandomAccessIndex<C: Collection>: _opaque_Strideable, Strideable {
    public typealias Value = C.Index
    public typealias Stride = Int

    public var collection: C
    public var value: Value

    @inlinable
    public init(_ collection: C, _ value: Value) {
        self.collection = collection
        self.value = value
    }

    @inlinable
    public func distance(to other: FauxRandomAccessIndex) -> Int {
        return collection.distance(from: value, to: other.value)
    }

    @inlinable
    public func advanced(by n: Stride) -> FauxRandomAccessIndex {
        return .init(collection, collection.index(collection.startIndex, offsetBy: collection.distance(from: collection.startIndex, to: value) + n))
    }
}
