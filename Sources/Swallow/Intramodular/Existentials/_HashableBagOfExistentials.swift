//
// Copyright (c) Vatsal Manot
//

import Swift

@frozen
public struct _HashableBagOfExistentials<Existential> {
    private var base: _BagOfExistentials<Existential>
    
    public var count: Int {
        base.count
    }
    
    init(base: _BagOfExistentials<Existential>) {
        self.base = base
    }
}

extension _HashableBagOfExistentials {
    public func all<T>(ofType type: T.Type) -> AnyCollection<T> {
        base.all(ofType: type)
    }
    
    public mutating func insert(_ element: Existential) {
        base.insert(element)
    }
    
    public mutating func remove(_ element: Existential) {
        base.remove(element)
    }
    
    public mutating func removeAll(
        where shouldBeRemoved: (Existential) throws -> Bool
    ) rethrows {
        try base.removeAll(where: shouldBeRemoved)
    }
    
    public func contains(
        _ element: Existential
    ) -> Bool {
        base.contains(element)
    }
    
    public func contains<T>(
        type: T.Type
    ) -> Bool {
        base.contains(type: type)
    }
    
    public func first<T>(
        ofType type: T.Type
    ) -> T? {
        base.first(ofType: type)
    }
    
    public func firstAndOnly<T>(
        ofType type: T.Type
    ) throws -> T? {
        try base.firstAndOnly(ofType: type)
    }
    
    public mutating func insert(
        contentsOf elements: some Sequence<Existential>
    ) {
        base.insert(contentsOf: elements)
    }
    
    public func inserting(
        _ element: Existential
    ) -> Self {
        build(self, with: { $0.insert(element) })
    }
    
    public mutating func removeAll<T>(
        ofType type: T.Type
    ) {
        base.removeAll(ofType: type)
    }
    
    public mutating func removeAll(
        ofType type: Any.Type
    ) {
        base.removeAll(ofType: type)
    }
    
    public mutating func replaceAll<T>(
        ofType type: T.Type,
        with element: Existential
    ) {
        base.replaceAll(ofType: type, with: element)
    }
}

// MARK: - Conformances

extension _HashableBagOfExistentials: CustomStringConvertible {
    public var description: String {
        base.description
    }
}

extension _HashableBagOfExistentials: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Existential...) {
        self.init(elements)
    }
}

extension _HashableBagOfExistentials: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        do {
            let lhs = try lhs.map({ try _HashableExistential(erasing: $0) })
            let rhs = try rhs.map({ try _HashableExistential(erasing: $0) })
            
            return lhs == rhs
        } catch {
            assertionFailure()
            
            return false
        }
    }
}

extension _HashableBagOfExistentials: Hashable {
    public func hash(into hasher: inout Hasher) {
        do {
            try self.map({ try _HashableExistential(erasing: $0) }).hash(into: &hasher)
        } catch {
            assertionFailure(error)
        }
    }
}

extension _HashableBagOfExistentials: Initiable {
    public init() {
        self.base = .init()
    }
    
    public init() where Existential == Any {
        self.base = .init()
    }
}

extension _HashableBagOfExistentials: MergeOperatable {
    public mutating func mergeInPlace(
        with other: Self
    ) {
        self = Self(AnySequence(self).join(AnySequence(other)))
    }
}

extension _HashableBagOfExistentials: SequenceInitiableSequence {
    public init(_ elements: some Sequence<Existential>) {
        self.base = .init(elements)
    }

    public func makeIterator() -> AnyIterator<Existential> {
        base.makeIterator()
    }
}
