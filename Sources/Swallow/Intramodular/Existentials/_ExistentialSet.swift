//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _ExistentialSet<Existential>: Hashable {
    public typealias Element = Existential
    
    private var elements: Set<_Element> = []
    
    fileprivate init(elements: Set<_Element>) {
        self.elements = elements
    }
    
    public init() {
        
    }
    
    public init() where Existential == Any {
        
    }
    
    public init(_ elements: some Sequence<Existential>) {
        self.init()
        
        for element in elements {
            insert(element)
        }
    }
    
    public mutating func removeAll(
        where shouldBeRemoved: (Existential) throws -> Bool
    ) rethrows {
        try elements.removeAll(where: { try shouldBeRemoved($0.value) })
    }
    
    public func contains<T>(type: T.Type) -> Bool {
        self.contains(where: { _isValueOfGivenType($0, type: type) })
    }
}

extension _ExistentialSet {
    public var _typeErased: Set<AnyHashable> {
        get {
            do {
                return try Set(lazy.map({ try cast($0, to: (any Hashable).self).erasedAsAnyHashable }))
            } catch {
                assertionFailure()

                return []
            }
        } set {
            guard let newValue = try? newValue.map({ try cast($0.base, to: Existential.self) }) else {
                assertionFailure()
                
                return
            }
                        
            self = .init(newValue)
        }
    }
}

extension _ExistentialSet {
    public func first<T>(ofType type: T.Type) -> T? {
        self.first(where: { _isValueOfGivenType($0, type: type) }).map({ $0 as! T })
    }
    
    public func firstAndOnly<T>(ofType type: T.Type) throws -> T? {
        try self.filter({ _isValueOfGivenType($0, type: type) }).firstAndOnly(ofType: type)
    }
    
    public func all<T>(ofType type: T.Type) -> AnyCollection<T> {
        AnyCollection(elements.lazy.compactMap({ $0 as? T }))
    }
    
    public mutating func removeAll<T>(ofType type: T.Type) {
        removeAll(where: { _isValueOfGivenType($0, type: type) })
    }
    
    public mutating func replaceAll<T>(ofType type: T.Type, with element: Existential) {
        removeAll(ofType: type)
        
        insert(element)
    }
}

// MARK: - Conformances

extension _ExistentialSet: Sendable where Element: Sendable {
    
}

extension _ExistentialSet: Sequence {
    public func makeIterator() -> AnyIterator<Existential> {
        AnyIterator(elements.lazy.map({ $0.value }).makeIterator())
    }
}

extension _ExistentialSet {
    public var count: Int {
        elements.count
    }
}

extension _ExistentialSet: SequenceInitiableSetProtocol {
    public func contains(_ element: Existential) -> Bool {
        elements.contains(.init(element))
    }
    
    public func isSubset(of other: Self) -> Bool {
        elements.isSubset(of: other.elements)
    }
    
    public func isSubset(of other: some Sequence<Existential>) -> Bool  {
        isSubset(of: Self(other))
    }
    
    public func isSuperset(of other: Self) -> Bool {
        elements.isSuperset(of: other.elements)
    }
    
    public func isSuperset(of other: some Sequence<Existential>) -> Bool {
        isSuperset(of: Self(other))
    }
    
    public func intersection(
        _ other: some Sequence<Existential>
    ) -> Self {
        Self(elements: elements.intersection(Self(other).elements))
    }
        
    public mutating func insert(_ element: Existential) {
        elements.insert(.init(element))
    }
    
    public func inserting(_ element: Existential) -> Self {
        build(self) {
            $0.insert(element)
        }
    }
    
    public mutating func remove(_ element: Existential) {
        elements.remove(.init(element))
    }
    
    public func union(_ other: Self) -> Self {
        Self(elements: elements.union(other.elements))
    }
    
    public func union(_ other: some Sequence<Existential>) -> Self {
        union(Self(other))
    }
    
    public func intersection(_ other: Self) -> Self {
        Self(elements: elements.intersection(other.elements))
    }
}

extension _ExistentialSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Existential...) {
        self.init(elements)
    }
}

// MARK: - Auxiliary

extension _ExistentialSet {
    fileprivate struct _Element: Hashable {
        let value: Existential
        
        private var type: ObjectIdentifier {
            ObjectIdentifier(Swift.type(of: value))
        }
        
        public init(_ value: Existential) {
            guard value is any Hashable else {
                fatalError()
            }
            
            self.value = value
        }
        
        public func hash(into hasher: inout Hasher) {
            (value as! any Hashable).hash(into: &hasher)
            
            type.hash(into: &hasher)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.type == rhs.type && AnyEquatable.equate(lhs.value, rhs.value)
        }
    }
}
