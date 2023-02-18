//
// Copyright (c) Vatsal Manot
//

import Swift

struct _CollectionOnly<C: Collection> {
    typealias Value = C
    
    var value: Value
    
    @inlinable init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Conformances

extension _CollectionOnly: Collection {
    typealias Element = Value.Element
    typealias Index = Value.Index
    
    @inlinable var startIndex: Index {
        return value.startIndex
    }
    
    @inlinable var endIndex: Index {
        return value.endIndex
    }
    
    subscript(index: Index) -> Element {
        @inlinable get {
            return value[index]
        }
    }
    
    @inlinable func index(after index: Index) -> Index {
        return value.index(index, offsetBy: 1)
    }
}

extension _CollectionOnly: Sequence {
    typealias Iterator = Value.Iterator
    
    @inlinable func makeIterator() -> Iterator {
        return value.makeIterator()
    }
}
