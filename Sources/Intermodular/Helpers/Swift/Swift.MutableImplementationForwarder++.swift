//
// Copyright (c) Vatsal Manot
//

import Swift

// MARK: -

extension MutableImplementationForwarder where Self: DestructivelyMutableSequence, ImplementationProvider: DestructivelyMutableSequence, ImplementationProvider.Element == Self.Element {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try implementationProvider.forEach(mutating: iterator)
    }
    
    public mutating func forEach<T>(mutating iterator: ((inout Element?) throws -> T)) rethrows {
        try implementationProvider.forEach(mutating: iterator)
    }
    
    public mutating func removeAll() {
        implementationProvider.removeAll()
    }
}

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, ImplementationProvider.Element == Self.Element {
    public mutating func forEach<T>(mutating iterator: ((inout Element?) throws -> T)) rethrows {
        try implementationProvider.forEach(mutating: iterator)
    }
    
    public mutating func removeAll() {
        implementationProvider.removeAll()
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: ExtensibleSequence, ImplementationProvider: ExtensibleSequence, Self.ImplementationProvider.Element == Self.Element, Self.ElementInsertResult == ImplementationProvider.ElementInsertResult, Self.ElementsInsertResult == ImplementationProvider.ElementsInsertResult {
    public mutating func insert(_ newElement: Element) -> ElementInsertResult {
        return implementationProvider.insert(newElement)
    }
    
    public mutating func insert<S: Sequence>(contentsOf newElements: S) -> ElementsInsertResult where S.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
    
    public mutating func insert<C: Collection>(contentsOf newElements: C) -> ElementsInsertResult where C.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
}

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, Self.ImplementationProvider.Element == Self.Element, Self.ElementInsertResult == ImplementationProvider.ElementInsertResult, Self.ElementsInsertResult == ImplementationProvider.ElementsInsertResult {
    public mutating func insert(_ newElement: Element) -> ElementInsertResult {
        return implementationProvider.insert(newElement)
    }
    
    public mutating func insert<S: Sequence>(contentsOf newElements: S) -> ElementsInsertResult where S.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
    
    public mutating func insert<C: Collection>(contentsOf newElements: C) -> ElementsInsertResult where C.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
}

extension MutableImplementationForwarder where Self: ExtensibleSequence, ImplementationProvider: ExtensibleSequence, Self.ImplementationProvider.Element == Self.Element, Self.ElementInsertResult == ImplementationProvider.ElementInsertResult, Self.ElementsInsertResult == ImplementationProvider.ElementsInsertResult, Self.ElementInsertResult == Void, Self.ElementsInsertResult == Void {
    public mutating func insert(_ newElement: Element) -> ElementInsertResult {
        return implementationProvider.insert(newElement)
    }
    
    public mutating func insert<S: Sequence>(contentsOf newElements: S) -> ElementsInsertResult where S.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
    
    public mutating func insert<C: Collection>(contentsOf newElements: C) -> ElementsInsertResult where C.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
}

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, Self.ImplementationProvider.Element == Self.Element, Self.ElementInsertResult == ImplementationProvider.ElementInsertResult, Self.ElementsInsertResult == ImplementationProvider.ElementsInsertResult, Self.ElementInsertResult == Void, Self.ElementsInsertResult == Void {
    public mutating func insert(_ newElement: Element) -> ElementInsertResult {
        return implementationProvider.insert(newElement)
    }
    
    public mutating func insert<S: Sequence>(contentsOf newElements: S) -> ElementsInsertResult where S.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
    
    public mutating func insert<C: Collection>(contentsOf newElements: C) -> ElementsInsertResult where C.Element == Element {
        return implementationProvider.insert(contentsOf: newElements)
    }
}

extension MutableImplementationForwarder where Self: ExtensibleSequence, ImplementationProvider: ExtensibleSequence, Self.ImplementationProvider.Element == Self.Element, Self.ElementAppendResult == ImplementationProvider.ElementAppendResult, Self.ElementsAppendResult == ImplementationProvider.ElementsAppendResult {
    public mutating func append(_ newElement: Element) -> ElementAppendResult {
        return implementationProvider.append(newElement)
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) -> ElementsAppendResult where S.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
    
    public mutating func append<C: Collection>(contentsOf newElements: C) -> ElementsAppendResult where C.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
}

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, Self.ImplementationProvider.Element == Self.Element, Self.ElementAppendResult == ImplementationProvider.ElementAppendResult, Self.ElementsAppendResult == ImplementationProvider.ElementsAppendResult {
    public mutating func append(_ newElement: Element) -> ElementAppendResult {
        return implementationProvider.append(newElement)
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) -> ElementsAppendResult where S.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
    
    public mutating func append<C: Collection>(contentsOf newElements: C) -> ElementsAppendResult where C.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
}

extension MutableImplementationForwarder where Self: ExtensibleSequence, ImplementationProvider: ExtensibleSequence, Self.ImplementationProvider.Element == Self.Element, Self.ElementAppendResult == ImplementationProvider.ElementAppendResult, Self.ElementsAppendResult == ImplementationProvider.ElementsAppendResult, Self.ElementAppendResult == Void, Self.ElementsAppendResult == Void {
    public mutating func append(_ newElement: Element) -> ElementAppendResult {
        return implementationProvider.append(newElement)
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) -> ElementsAppendResult where S.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
    
    public mutating func append<C: Collection>(contentsOf newElements: C) -> ElementsAppendResult where C.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
}

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, Self.ImplementationProvider.Element == Self.Element, Self.ElementAppendResult == ImplementationProvider.ElementAppendResult, Self.ElementsAppendResult == ImplementationProvider.ElementsAppendResult, Self.ElementAppendResult == Void, Self.ElementsAppendResult == Void {
    public mutating func append(_ newElement: Element) -> ElementAppendResult {
        return implementationProvider.append(newElement)
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) -> ElementsAppendResult where S.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
    
    public mutating func append<C: Collection>(contentsOf newElements: C) -> ElementsAppendResult where C.Element == Element {
        return implementationProvider.append(contentsOf: newElements)
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: IteratorProtocol, ImplementationProvider: IteratorProtocol, Self.Element == ImplementationProvider.Element {
    public mutating func next() -> Element? {
        return implementationProvider.next()
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: MutableCollection, ImplementationProvider: MutableCollection, Self.Element == ImplementationProvider.Element, Self.Index == ImplementationProvider.Index {
    public subscript(position: Index) -> Element {
        get {
            return implementationProvider[position]
        } set {
            implementationProvider[position] = newValue
        }
    }
}

extension MutableImplementationForwarder where Self: MutableCollection, ImplementationProvider: MutableCollection, Self.Index == ImplementationProvider.Index, Self.SubSequence == ImplementationProvider.SubSequence {
    public subscript(bounds: Range<Index>) -> ImplementationProvider.SubSequence {
        get {
            return implementationProvider[bounds]
        } set {
            implementationProvider[bounds] = newValue
        }
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: MutableDictionaryProtocol, ImplementationProvider: MutableDictionaryProtocol, Self.DictionaryKey == ImplementationProvider.DictionaryKey, Self.DictionaryValue == ImplementationProvider.DictionaryValue {
    public mutating func setValue(_ value: DictionaryValue, forKey key: DictionaryKey) {
        implementationProvider.setValue(value, forKey: key)
    }
    
    @discardableResult public mutating func updateValue(_ value: DictionaryValue, forKey key: DictionaryKey) -> DictionaryValue? {
        return implementationProvider.updateValue(value, forKey: key)
    }
    
    @discardableResult public mutating func removeValue(forKey key: DictionaryKey) -> DictionaryValue? {
        return implementationProvider.removeValue(forKey: key)
    }
    
    public subscript(key: DictionaryKey) -> DictionaryValue? {
        get {
            return implementationProvider[key]
        } set {
            implementationProvider[key] = newValue
        }
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: MutableSequence, ImplementationProvider: MutableSequence, Self.Element == ImplementationProvider.Element {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try implementationProvider.forEach(mutating: iterator)
    }
}

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, ImplementationProvider.Element == Self.Element {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try implementationProvider.forEach(mutating: iterator)
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: Numeric, ImplementationProvider: Numeric, Self.Magnitude == ImplementationProvider.Magnitude {
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.implementationProvider += rhs.implementationProvider
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.implementationProvider -= rhs.implementationProvider
    }
    
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs.implementationProvider *= rhs.implementationProvider
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: RangeReplaceableCollection, ImplementationProvider: RangeReplaceableCollection {
    public mutating func reserveCapacity(_ n: Int) {
        implementationProvider.reserveCapacity(n)
    }
}

extension MutableImplementationForwarder where Self: RangeReplaceableCollection, ImplementationProvider: RangeReplaceableCollection, Self.Index == ImplementationProvider.Index, Self.Element == ImplementationProvider.Element {
    public mutating func replaceSubrange<C: Collection>(_ bounds: Range<Index>, with newElements: C) where C.Element == Element {
        implementationProvider.replaceSubrange(bounds, with: newElements)
    }
}

extension MutableImplementationForwarder where Self: RangeReplaceableCollection, ImplementationProvider: RangeReplaceableCollection, Self.Element == ImplementationProvider.Element {
    public mutating func append(_ newElement: Element) {
        implementationProvider.append(newElement)
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        implementationProvider.append(contentsOf: newElements)
    }
}

// MARK: -

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, Self.Element == ImplementationProvider.Element, Self.Index == ImplementationProvider.Index, Self.SubSequence == ImplementationProvider.SubSequence {
    public subscript(position: Index) -> Element {
        get {
            return implementationProvider[position]
        } set {
            implementationProvider[position] = newValue
        }
    }
}

extension MutableImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, Self.Index == ImplementationProvider.Index, Self.SubSequence == ImplementationProvider.SubSequence {
    public subscript(bounds: Range<Index>) -> ImplementationProvider.SubSequence {
        get {
            return implementationProvider[bounds]
        } set {
            implementationProvider[bounds] = newValue
        }
    }
}
