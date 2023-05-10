//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _HashableExistentialArray<Existential>: Hashable {
    private var base: [AnyHashable]
    
    init(base: [AnyHashable]) {
        self.base = base
    }
}

extension _HashableExistentialArray: MutableCollection, MutableSequence, RandomAccessCollection {
    public typealias Element = Existential
    
    public var count: Int {
        base.count
    }
    
    public var startIndex: Int {
        base.startIndex
    }
    
    public var endIndex: Int {
        base.endIndex
    }
    
    public subscript(_ index: Int) -> Element {
        get {
            base[index].base as! Element
        } set {
            base[index] = (newValue as! any Hashable).erasedAsAnyHashable
        }
    }
}

extension _HashableExistentialArray {
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == Element {
        base.replaceSubrange(
            subrange,
            with: newElements.map({ ($0 as! any Hashable).erasedAsAnyHashable })
        )
    }
    
    public mutating func removeAll(of element: Element) {
        base.removeAll(of: (element as! any Hashable).erasedAsAnyHashable)
    }
}
