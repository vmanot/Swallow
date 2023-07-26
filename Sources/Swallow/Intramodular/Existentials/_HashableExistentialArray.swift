//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _HashableExistentialArray<Existential>: Hashable {
    private var base: [_HashableExistential<Existential>]
    
    fileprivate init(base: [_HashableExistential<Existential>]) {
        self.base = base
    }
    
    public init(_ sequence: some Sequence<Existential>) {
        self.init(base: sequence.map(_HashableExistential.init(_unsafelyErasing:)))
    }
}

// MARK: - Extensions

extension _HashableExistentialArray {
    public mutating func removeDuplicates() {
        base.removeDuplicates()
    }
}

// MARK: - Conformances

extension _HashableExistentialArray: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(Metatype(type(of: self)))(\(base.map({ $0.wrappedValue })))"
    }
}

extension _HashableExistentialArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Existential...) {
        self.init(base: elements.map(_HashableExistential<Existential>.init(_unsafelyErasing:)))
    }
}

extension _HashableExistentialArray: ExtensibleSequence, MutableCollection, MutableSequence, RandomAccessCollection {
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
            base[index].wrappedValue
        } set {
            base[index].wrappedValue = newValue
        }
    }
    
    public mutating func insert(_ element: Existential) {
        base.insert(_HashableExistential(_unsafelyErasing: element), at: 0)
    }
    
    public mutating func append(_ element: Existential) {
        base.append(_HashableExistential(_unsafelyErasing: element))
    }
    
    public mutating func append(contentsOf elements: some Sequence<Existential>) {
        base.append(contentsOf: elements.map(_HashableExistential.init(_unsafelyErasing:)))
    }

    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == Element {
        base.replaceSubrange(
            subrange,
            with: newElements.map(_HashableExistential.init(_unsafelyErasing:))
        )
    }
    
    public mutating func removeAll(of element: Element) {
        base.removeAll(of: _HashableExistential(_unsafelyErasing: element))
    }
}

extension _HashableExistentialArray: @unchecked Sendable {
    
}
