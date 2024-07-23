//
// Copyright (c) Vatsal Manot
//

import OrderedCollections
import Swift

public typealias IdentifierIndexingArrayOf<Element: Identifiable> = IdentifierIndexingArray<Element, Element.ID>

public protocol IdentifierIndexingArrayType: Collection {
    associatedtype ID: Hashable
}

/// An array that additionally indexes elements by ID.
public struct IdentifierIndexingArray<Element, ID: Hashable>: IdentifierIndexingArrayType {
    private(set) var base: OrderedCollections.OrderedDictionary<ID, Element>
    
    public let id: (Element) -> ID
    
    public var identifiers: AnyRandomAccessCollection<ID> {
        .init(OrderedSet(base.keys))
    }
    
    public var _unorderedIdentifiers: Set<ID> {
        Set(base.keys)
    }
    
    public init(
        _ elements: some Sequence<Element>,
        id: @escaping (Element) -> ID
    ) {
        self.base = OrderedCollections.OrderedDictionary(
            uniqueKeysWithValues: elements.distinct(by: id).map({ (key: id($0), value: $0) })
        )
        self.id = id
    }
    
    public init(
        _ elements: some Sequence<Element>,
        id: @escaping (Element) -> ID
    ) where Element: Equatable {
        self.base = OrderedCollections.OrderedDictionary(
            elements.map({ (key: id($0), value: $0) }),
            uniquingKeysWith: { (lhs: Element, rhs: Element) -> Element in
                assert(id(lhs) == id(rhs))
                
                return lhs
            }
        )
        self.id = id
    }
    
    public init(
        id: @escaping (Element) -> ID
    ) {
        self.init(Array<Element>(), id: id)
    }
    
    public init(
        _ elements: some Sequence<Element>,
        id: KeyPath<Element, ID>
    ) {
        self.init(elements, id: { $0[keyPath: id] })
    }
    
    public init(
        _ elements: some Sequence<Element>,
        id: KeyPath<Element, ID>
    ) where Element: Equatable {
        self.init(elements, id: { $0[keyPath: id] })
    }
    
    public init(
        id: KeyPath<Element, ID>
    ) {
        self.init(id: { $0[keyPath: id] })
    }
    
    public init(
        _ elements: some Sequence<Element>
    ) where Element: Identifiable, Element.ID == ID {
        self.init(elements, id: \.id)
    }
    
    public init(
        _ elements: some Sequence<Element>
    ) where Element: Equatable & Identifiable, Element.ID == ID {
        self.init(elements, id: \.id)
    }
    
    private func _idForElement(
        _ element: Element
    ) -> ID {
        id(element)
    }
    
    public func contains(
        elementIdentifiedBy id: ID
    ) -> Bool {
        base.keys.contains(id)
    }
}

// MARK: - Implementation

extension IdentifierIndexingArray {
    public mutating func append(_ element: Element) {
        self[id: _idForElement(element)] = element
    }
    
    public mutating func append<S: Sequence>(
        contentsOf newElements: S
    ) where S.Element == Element {
        for element in newElements {
            base.updateValue(element, forKey: self._idForElement(element))
        }
    }
    
    public func appending(_ element: Element) -> Self {
        build(self, with: {
            $0.append(element)
        })
    }
}

extension IdentifierIndexingArrayOf {
    public func element(before other: ID) -> Element? {
        guard let index = self.index(of: other), index > startIndex else {
            return nil
        }
        
        let previousIndex = self.index(before: index)
        
        guard previousIndex < endIndex else {
            return nil
        }
        
        return self[previousIndex]
    }
    
    public func element(before other: Element) -> Element? {
        self.element(before: _idForElement(other))
    }
    
    public func element(after other: ID) -> Element? {
        guard let index = self.index(of: other), let lastIndex, index < lastIndex else {
            return nil
        }
        
        let nextIndex = self.index(after: index)
        
        guard nextIndex < endIndex else {
            return nil
        }
        
        return self[nextIndex]
    }
    
    public func element(after other: Element) -> Element? {
        self.element(after: _idForElement(other))
    }
    
    public func sorted(
        by areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool
    ) rethrows -> Self {
        IdentifierIndexingArray(try sorted(by: areInIncreasingOrder) as Array, id: id)
    }
    
    public func map<T: Identifiable>(
        _ transform: (Element) throws -> T
    ) rethrows -> IdentifierIndexingArrayOf<T> {
        try IdentifierIndexingArrayOf<T>(Array(self).map({ try transform($0) }))
    }
    
    public func map<T, U: Hashable>(
        id: KeyPath<T, U>,
        _ transform: (Element) throws -> T
    ) rethrows -> IdentifierIndexingArray<T, U> {
        try IdentifierIndexingArray<T, U>(Array(self).map({ try transform($0) }), id: id)
    }
}

// MARK: - Conformances

extension IdentifierIndexingArray: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        base.debugDescription
    }
    
    public var description: String {
        base.description
    }
}

extension IdentifierIndexingArray: Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

extension IdentifierIndexingArray: ExpressibleByArrayLiteral where Element: Identifiable, Element.ID == ID {
    public init(arrayLiteral elements: Element...) {
        self.init(elements, id: \.id)
    }
}

extension IdentifierIndexingArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}

extension IdentifierIndexingArray: _ThrowingInitiable, Initiable where Element: Identifiable, Element.ID == ID {
    public init() {
        self.init([], id: \.id)
    }
}

extension IdentifierIndexingArray: MutableCollection, MutableSequence, RandomAccessCollection {
    public var count: Int {
        base.count
    }
    
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        base.count
    }
    
    public subscript(_ index: Int) -> Element {
        get {
            guard index < endIndex else {
                assertionFailure()
                
                return try! _generatePlaceholder()
            }
            
            return base.elements[index].value
        } set {
            base.updateValue(newValue, forKey: _idForElement(newValue), insertingAt: index)
        }
    }
    
    // TODO: Optimize
    public mutating func move(
        fromOffsets source: IndexSet,
        toOffset destination: Int
    ) {
        var _self = Array(self)
        
        _self.move(fromOffsets: source, toOffset: destination)
        
        self = Self(_self, id: self.id)
    }
    
    public subscript(
        id identifier: ID
    ) -> Element? {
        get {
            base[identifier]
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
        _optionalID identifier: ID?
    ) -> Element? {
        get {
            identifier.flatMap({ self[id: $0] })
        } set {
            guard let identifier = identifier else {
                assertionFailure()
                
                return
            }
            
            self[id: identifier] = newValue
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
    
    public subscript(
        id identifier: ID,
        defaultInPlace defaultValue: @autoclosure () -> Element
    ) -> Element {
        mutating get {
            if let result = self[id: identifier] {
                return result
            } else {
                let result = defaultValue()
                
                self[id: identifier] = result
                
                return result
            }
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
    
    public func index(ofElementIdentifiedBy id: ID) -> Int? {
        base.index(forKey: id)
    }
}

extension IdentifierIndexingArray {
    private mutating func _naivelyModifyBase(
        _ operation: (inout [(key: ID, value: Element)]) throws -> Void
    ) rethrows {
        var _base = Array(base)
        
        try operation(&_base)
        
        self.base = .init(uniqueKeysWithValues: _base)
    }
    
    public mutating func insert(
        _ newElement: Element
    ) {
        base.updateValue(newElement, forKey: _idForElement(newElement), insertingAt: 0)
    }
    
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Index>,
        with newElements: C
    ) where C.Element == Element {
        let _id = self._idForElement
        
        _naivelyModifyBase {
            $0.replaceSubrange(subrange, with: newElements.map({ (_id($0), $0) }))
        }
    }
    
    public mutating func removeAll(
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
        try _naivelyModifyBase {
            try $0.removeAll(where: { try shouldBeRemoved($0.value) })
        }
    }
    
    public mutating func removeSubrange(
        _ subrange: Range<Index>
    ) {
        _naivelyModifyBase {
            $0.removeSubrange(subrange)
        }
    }
    
    public mutating func remove(_ element: Element) {
        base.removeValue(forKey: _idForElement(element))
    }
    
    public mutating func removeAll(after index: Index) {
        guard index < endIndex else {
            return
        }
        
        let rangeToRemove = index.advanced(by: 1)..<endIndex
        
        removeSubrange(rangeToRemove)
    }
    
    @discardableResult
    public mutating func remove(
        elementIdentifiedBy id: ID
    ) -> Element? {
        guard let element = base.removeValue(forKey: id) else {
            return nil
        }
        
        return element
    }
    
    public mutating func removeAll(
        identifiedBy sequence: some Sequence<ID>
    ) {
        let keys = Set(sequence)
        
        base.removeAll(where: { keys.contains($0.key) })
    }
    
    @available(*, deprecated, renamed: "remove(elementIdentifiedBy:)")
    @discardableResult
    public mutating func removeAll(
        identifiedBy id: ID
    ) -> Element? {
        remove(elementIdentifiedBy: id)
    }
    
    @discardableResult
    public mutating func update(_ element: Element) -> Element? {
        base.updateValue(element, forKey: _idForElement(element))
    }
    
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func upsert(
        _ element: Element
    ) {
        if update(element) == nil {
            append(element)
        }
    }
    
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func upsert<S: Sequence>(
        contentsOf elements: S
    ) where S.Element == Element {
        elements.forEach({ upsert($0) })
    }
    
    public mutating func upsert(
        _ element: Element,
        uniquingValuesWith unique: (Element, Element) throws -> Element
    ) rethrows {
        let id = _idForElement(element)
        
        if let existing = self[id: id] {
            self[id: id] = try unique(existing, element)
        } else {
            self.append(element)
        }
    }
    
    public mutating func upsert<S: Sequence>(
        contentsOf elements: S,
        uniquingValuesWith unique: (Element, Element) throws -> Element
    ) rethrows where S.Element == Element {
        try elements.forEach({ try upsert($0, uniquingValuesWith: unique) })
    }
    
    public mutating func upsert<S: Sequence>(
        contentsOf elements: S
    ) where Element: MergeOperatable, S.Element == Element {
        self.upsert(contentsOf: elements, uniquingValuesWith: { $0.mergingInPlace(with: $1) })
    }
    
    public mutating func upsert<S: Sequence>(
        contentsOf elements: S
    ) throws where Element: ThrowingMergeOperatable, S.Element == Element {
        try self.upsert(contentsOf: elements, uniquingValuesWith: { try $0.mergingInPlace(with: $1) })
    }
    
    public mutating func remove(
        atOffsets indexSet: IndexSet
    ) {
        _naivelyModifyBase {
            $0.remove(atOffsets: indexSet)
        }
    }
}

extension IdentifierIndexingArray: RangeReplaceableCollection where Element: Identifiable, Element.ID == ID {
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func updateOrAppend(_ element: Element) {
        if let index = self.index(of: _idForElement(element)) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
}

extension IdentifierIndexingArray: @unchecked Sendable where Element: Sendable, ID: Sendable {
    
}

extension IdentifierIndexingArray: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        AnyIterator(base.values.makeIterator())
    }
}

extension IdentifierIndexingArray: Decodable where Element: Decodable, Element: Identifiable, Element.ID == ID {
    public init(
        from decoder: Decoder
    ) throws {
        self.init(try decoder.singleValueContainer().decode([Element].self), id: \.id)
    }
}

extension IdentifierIndexingArray: Encodable where Element: Encodable, Element: Identifiable, Element.ID == ID {
    public func encode(
        to encoder: Encoder
    ) throws {
        try base.map({ $0.value }).encode(to: encoder)
    }
}

// MARK: - Supplementary

extension Sequence {
    public func identified<T: Hashable>(
        by keyPath: KeyPath<Element, T>
    ) -> IdentifierIndexingArray<Element, T> {
        IdentifierIndexingArray(self, id: keyPath)
    }
    
    @_disfavoredOverload
    public func map<T: Identifiable>(
        _ transform: (@escaping (Element) throws -> T)
    ) rethrows -> IdentifierIndexingArrayOf<T> {
        IdentifierIndexingArrayOf(try self.lazy.map({ try transform($0) }), id: \.id)
    }
    
    @_disfavoredOverload
    public func flatMap<S: Sequence>(
        _ transform: (@escaping (Element) throws -> S)
    ) rethrows -> IdentifierIndexingArrayOf<S.Element> where S.Element: Identifiable {
        IdentifierIndexingArrayOf(try self.flatMap({ try transform($0) }), id: \.id)
    }
}

// MARK: - SwiftUI Additions

#if canImport(SwiftUI)
import SwiftUI

extension Binding {
    public subscript<Element, ID: Hashable>(
        id identifier: ID
    ) -> Binding<Element>? where Value == IdentifierIndexingArray<Element, ID> {
        guard let currentValue = self.wrappedValue[id: identifier] else {
            return nil
        }
        
        return Binding<Element>(
            get: {
                guard let value = self.wrappedValue[id: identifier] else {
                    assertionFailure()
                    
                    return currentValue
                }
                
                return value
            },
            set: {
                self.wrappedValue[id: identifier] = $0
            }
        )
    }
    
    public subscript<Element, ID: Hashable>(
        id identifier: ID,
        default defaultValue: @autoclosure @escaping () -> Element
    ) -> Binding<Element> where Value == IdentifierIndexingArray<Element, ID> {
        .init(
            get: {
                self.wrappedValue[id: identifier, default: defaultValue()]
            },
            set: {
                self.wrappedValue[id: identifier] = $0
            }
        )
    }
    
    public subscript<Element, ID: Hashable>(
        unsafelyUnwrappingElementIdentifiedBy identifier: ID
    ) -> Binding<Element> where Value == IdentifierIndexingArray<Element, ID> {
        .init(
            get: {
                self.wrappedValue[id: identifier]!
            },
            set: {
                self.wrappedValue[id: identifier] = $0
            }
        )
    }
}

extension ForEach where Content: View {
    public init(
        _ data: Data,
        from binding: Binding<IdentifierIndexingArrayOf<Data.Element>>,
        @ViewBuilder content: @escaping (Binding<Data.Element>) -> Content
    ) where Data.Element: Identifiable, ID == Data.Element.ID {
        self.init(data) { (element: Data.Element) in
            let binding = Binding<Data.Element>(
                get: {
                    element
                },
                set: { (newValue: Data.Element) in
                    binding.wrappedValue.upsert(newValue)
                }
            )
            
            content(binding)
        }
    }
    
    public init<Element: Identifiable, UnwrappedContent: View>(
        identified data: Binding<IdentifierIndexingArrayOf<Element>>,
        @ViewBuilder content: @escaping (Binding<Element>) -> UnwrappedContent
    ) where Data == LazyMapSequence<IdentifierIndexingArrayOf<Element>.Indices, (IdentifierIndexingArrayOf<Element>.Index, ID)>, ID == Element.ID, IdentifierIndexingArrayOf<Element>.Index: Hashable, Content == SwiftUI._ConditionalContent<UnwrappedContent, EmptyView>
    {
        self.init(data, id: \.id) { $element in
            let id = element.id
            let element: Element = $element.wrappedValue
            
            let binding = Binding<Element>(
                get: {
                    return element
                },
                set: { (newValue: Element) in
                    guard data.wrappedValue.contains(elementIdentifiedBy: id) else {
                        return
                    }
                    
                    $element.wrappedValue = newValue
                }
            )
            
            if data.wrappedValue.contains(elementIdentifiedBy: id) {
                content(binding)
            } else {
                EmptyView()
            }
        }
    }
    
    public init<Element: Identifiable & Initiable, UnwrappedContent: View>(
        identified data: Binding<IdentifierIndexingArrayOf<Element>>,
        @ViewBuilder content: @escaping (Binding<Element>) -> UnwrappedContent
    ) where Data == LazyMapSequence<IdentifierIndexingArrayOf<Element>.Indices, (IdentifierIndexingArrayOf<Element>.Index, ID)>, ID == Element.ID, IdentifierIndexingArrayOf<Element>.Index: Hashable, Content == SwiftUI._ConditionalContent<UnwrappedContent, EmptyView>
    {
        self.init(data, id: \.id) { $element in
            let elementBox = _UncheckedSendable(element)
            let id = element.id
            let binding = Binding<Element>(
                get: {
                    if data.wrappedValue.contains(elementIdentifiedBy: id) {
                        return elementBox.wrappedValue
                    } else {
                        runtimeIssue("Recovering by creating placeholder element.")
                        
                        return Element() // FIXME?
                    }
                },
                set: { (newValue: Element) in
                    guard data.wrappedValue.contains(elementIdentifiedBy: id) else {
                        return
                    }
                    
                    $element.wrappedValue = newValue
                }
            )
            
            if data.wrappedValue.contains(elementIdentifiedBy: id) {
                content(binding)
            } else {
                EmptyView()
            }
        }
    }
}

#endif
