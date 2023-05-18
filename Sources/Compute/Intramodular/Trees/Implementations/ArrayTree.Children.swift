//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct ArrayTreeChildren<TreeValue> {
    public typealias _ArrayRepresentation = [Element]
    public typealias Element = ArrayTree<TreeValue>
    
    private var base: _ArrayRepresentation
    
    init(base: _ArrayRepresentation) {
        self.base = base
    }
    
    public init() {
        self.init(base: [])
    }
}

extension ArrayTreeChildren: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = TreeValue
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(base: elements.map({ .init(value: $0) }))
    }
}

extension ArrayTreeChildren: ExpressibleByDictionaryLiteral {
    public typealias Key = TreeValue
    public typealias Value = Self
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements.map({ ArrayTree(value: $0.0, children: $0.1) }))
    }
}

extension ArrayTreeChildren: Equatable where TreeValue: Equatable {
    
}

extension ArrayTreeChildren: Hashable where TreeValue: Hashable {
    
}

extension ArrayTreeChildren: Sendable where TreeValue: Sendable {
    
}

extension ArrayTreeChildren: Countable, MutableCollection, RandomAccessCollection, RangeReplaceableCollection {
    public typealias Index = _ArrayRepresentation.Index
    public typealias Iterator = _ArrayRepresentation.Iterator
    
    public var startIndex: Index {
        base.startIndex
    }
    
    public var endIndex: Index {
        base.endIndex
    }
    
    public subscript(position: Index) -> Element {
        get {
            base[position]
        } set {
            base[position] = newValue
        }
    }
    
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Index>,
        with newElements: C
    ) where C.Element == Element {
        base.replaceSubrange(subrange, with: newElements)
    }
    
    public mutating func append(_ newElement: Element) {
        base.append(newElement)
    }
    
    public func makeIterator() -> Iterator {
        base.makeIterator()
    }
}

