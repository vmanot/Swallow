//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol SetProtocol<Element>: Countable, Sequence {
    func contains(_: Element) -> Bool
    
    func isSubset(of _: Self) -> Bool
    func isSuperset(of _: Self) -> Bool
}

public protocol SequenceInitiableSetProtocol<Element>: SequenceInitiableSequence, SetProtocol {
    func isSubset<S: Sequence>(of _: S) -> Bool where S.Element == Element
    func isSubset<C: Collection>(of _: C) -> Bool where C.Element == Element
    func isSuperset<S: Sequence>(of _: S) -> Bool where S.Element == Element
    func isSuperset<C: Collection>(of _: C) -> Bool where C.Element == Element
    
    func intersection<S: Sequence>(_: S) -> Self where S.Element == Element
    func intersection<C: Collection>(_: C) -> Self where C.Element == Element
    func intersection(_: Self) -> Self
    
    func union<S: Sequence>(_: S) -> Self where S.Element == Element
    func union<S: Collection>(_: S) -> Self where S.Element == Element
    func union(_: Self) -> Self
}

public protocol MutableSetProtocol<Element>: MutableSequence, SetProtocol {
    
}

public protocol ExtensibleSetProtocol<Element>: ExtensibleSequence, SetProtocol {
    
}

public protocol DestructivelyMutableSetProtocol<Element>: DestructivelyMutableSequence, ElementRemoveableDestructivelyMutableSequence, MutableSetProtocol {
    mutating func remove<S: Sequence>(contentsOf _: S) where S.Element == Element
}

public protocol ResizableSetProtocol<Element>: DestructivelyMutableSetProtocol, ExtensibleSetProtocol, ResizableSequence, SequenceInitiableSetProtocol {
    
}

// MARK: - Implementation

extension SequenceInitiableSetProtocol where Element: Hashable {
    public func isSubset<S: Sequence>(of other: S) -> Bool where S.Element == Element {
        return Set(other).isSubset(of: self)
    }
    
    public func isSuperset<S: Sequence>(of other: S) -> Bool where S.Element == Element {
        return isSuperset(of: Set(other))
    }
}

extension SequenceInitiableSetProtocol {
    public func intersection<S: SetProtocol>(_ other: S) -> Self where S.Element == Element {
        return _filter({ other.contains($0) })
    }
}

extension ExtensibleSetProtocol {
    public func union<S: Sequence>(_ other: S) -> Self where S.Element == Element {
        return build(self, with: { $0.append(contentsOf: other) })
    }
    
    public func union(_ other: Self) -> Self {
        return build(self, with: { $0.append(contentsOf: other) })
    }
}

extension DestructivelyMutableSetProtocol {
    public func removing(_ element: Element) -> Self {
        return build(self, with: { _ = $0.remove(element) })
    }
}
