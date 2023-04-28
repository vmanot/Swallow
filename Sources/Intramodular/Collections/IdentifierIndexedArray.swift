//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias IdentifierIndexedArrayOf<Element: Identifiable> = IdentifierIndexedArray<Element, Element.ID>

public struct IdentifierIndexedArray<Element, ID: Hashable> {
    private var base: OrderedDictionary<ID, Element>
    private var id: (Element) -> ID
    
    public init(_ elements: some Sequence<Element>, id: @escaping (Element) -> ID) {
        self.base = OrderedDictionary(uniqueKeysWithValues: elements.map({ (key: id($0), value: $0) }))
        self.id = id
    }
    
    public init(id: @escaping (Element) -> ID) {
        self.init(Array<Element>(), id: id)
    }
    
    public init(_ elements: some Sequence<Element>, id: KeyPath<Element, ID>) {
        self.init(elements, id: { $0[keyPath: id] })
    }
    
    public init(id: KeyPath<Element, ID>) {
        self.init(id: { $0[keyPath: id] })
    }
    
    public init(_ elements: some Sequence<Element>) where Element: Identifiable, Element.ID == ID {
        self.init(elements, id: \.id)
    }
    
    private func _idForElement(_ element: Element) -> ID {
        id(element)
    }
    
    public func contains(elementIdentifiedBy id: ID) -> Bool {
        base.containsKey(id)
    }
}

// MARK: - Implementation

extension IdentifierIndexedArray {
    public mutating func append(_ element: Element) {
        self[id: _idForElement(element)] = element
    }
    
    public func appending(_ element: Element) -> Self {
        build(self, with: {
            $0.append(element)
        })
    }
}

extension IdentifierIndexedArrayOf {
    public func map<T: Identifiable>(
        _ transform: (Element) throws -> T
    ) rethrows -> IdentifierIndexedArrayOf<T> {
        try IdentifierIndexedArrayOf<T>(Array(self).map({ try transform($0) }))
    }
    
    public func map<T, U: Hashable>(
        id: KeyPath<T, U>,
        _ transform: (Element) throws -> T
    ) rethrows -> IdentifierIndexedArray<T, U> {
        try IdentifierIndexedArray<T, U>(Array(self).map({ try transform($0) }), id: id)
    }
}

// MARK: - Conformances

extension IdentifierIndexedArray: CustomStringConvertible {
    public var description: String {
        Array(base).description
    }
}

extension IdentifierIndexedArray: CustomDebugStringConvertible {
    public var debugDescription: String {
        Array(base).debugDescription
    }
}

extension IdentifierIndexedArray: Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

extension IdentifierIndexedArray: ExpressibleByArrayLiteral where Element: Identifiable, Element.ID == ID {
    public init(arrayLiteral elements: Element...) {
        self.init(elements, id: \.id)
    }
}

extension IdentifierIndexedArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}

extension IdentifierIndexedArray: Initiable where Element: Identifiable, Element.ID == ID {
    public init() {
        self.init([], id: \.id)
    }
}

extension IdentifierIndexedArray: MutableCollection, MutableSequence, RandomAccessCollection {
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
            base[index].value
        } set {
            base[index] = (_idForElement(newValue), newValue)
        }
    }
    
    public subscript(id identifier: ID) -> Element? {
        get {
            base.value(forKey: identifier)
        } set {
            if let index = base.index(forKey: identifier) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    base.remove(at: index)
                }
            } else {
                if let newValue = newValue {
                    base.updateValue(newValue, forKey: identifier)
                } else {
                    // do nothing
                }
            }
        }
    }
    
    public subscript(
        id identifier: ID,
        default defaultValue: @autoclosure () -> Element
    ) -> Element {
        get {
            self[id: identifier] ?? defaultValue()
        } set {
            self[id: identifier] = newValue
        }
    }
    
    @_disfavoredOverload
    public subscript(id identifier: any Hashable) -> Element? where ID == AnyHashable {
        get {
            self[id: identifier.eraseToAnyHashable()]
        } set {
            self[id: identifier.eraseToAnyHashable()] = newValue
        }
    }
    
    public func index(of id: ID) -> Int? {
        base.index(forKey: id)
    }
}

extension IdentifierIndexedArray {
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == Element {
        var _base = Array(base)
        
        _base.replaceSubrange(subrange, with: newElements.map({ (_idForElement($0), $0) }))
        
        self.base = .init(uniqueKeysWithValues: _base)
    }
    
    public mutating func remove(_ element: Element) {
        self[id: _idForElement(element)] = nil
    }
    
    @discardableResult
    public mutating func update(_ element: Element) -> Element? {
        guard let index = self.index(of: _idForElement(element)) else {
            return nil
        }
        
        let oldElement = self[index]
        
        self[index] = element
        
        return oldElement
    }
}

extension IdentifierIndexedArray: RangeReplaceableCollection where Element: Identifiable, Element.ID == ID {
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func updateOrAppend(_ element: Element) {
        if let index = self.index(of: _idForElement(element)) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
}

extension IdentifierIndexedArray: @unchecked Sendable where Element: Sendable, ID: Sendable {
    
}

extension IdentifierIndexedArray: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        .init(base.lazy.map({ $0.value }).makeIterator())
    }
}

extension IdentifierIndexedArray: Decodable where Element: Decodable, Element: Identifiable, Element.ID == ID {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode([Element].self), id: \.id)
    }
}

extension IdentifierIndexedArray: Encodable where Element: Encodable, Element: Identifiable, Element.ID == ID {
    public func encode(to encoder: Encoder) throws {
        try base.map({ $0.value }).encode(to: encoder)
    }
}

// MARK: - Supplementary API

extension Sequence {
    public func identified<T: Hashable>(
        by keyPath: KeyPath<Element, T>
    ) -> IdentifierIndexedArray<Element, T> {
        IdentifierIndexedArray(self, id: keyPath)
    }

    @_disfavoredOverload
    public func map<T: Identifiable>(
        _ transform: (@escaping (Element) throws -> T)
    ) rethrows -> IdentifierIndexedArrayOf<T> {
        IdentifierIndexedArrayOf(try self.lazy.map({ try transform($0) }), id: \.id)
    }
}

// MARK: - SwiftUI Additions

#if canImport(SwiftUI)
import SwiftUI

extension Binding {
    public subscript<Element, ID: Hashable>(
        id identifier: ID,
        default defaultValue: @autoclosure @escaping () -> Element
    ) -> Binding<Element> where Value == IdentifierIndexedArray<Element, ID> {
        .init(
            get: {
                self.wrappedValue[id: identifier, default: defaultValue()]
            },
            set: {
                self.wrappedValue[id: identifier] = $0
            }
        )
    }
}
#endif
