//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _SetOfExistentials<Existential> {
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

extension _SetOfExistentials {
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

extension _SetOfExistentials: Sequence {
    public func makeIterator() -> AnyIterator<Existential> {
        AnyIterator(elements.lazy.map({ $0.value }).makeIterator())
    }
}

extension _SetOfExistentials: SetProtocol {
    public func contains(_ element: Existential) -> Bool {
        elements.contains(.init(element))
    }
    
    public func isSuperset(of other: Self) -> Bool {
        elements.isSuperset(of: other.elements)
    }
    
    public func isSubset(of other: Self) -> Bool {
        elements.isSubset(of: other.elements)
    }
    
    public mutating func insert(_ element: Existential) {
        elements.insert(.init(element))
    }
    
    public mutating func remove(_ element: Existential) {
        elements.remove(.init(element))
    }
    
    public func union(_ other: Self) -> Self {
        Self(elements: elements.union(other.elements))
    }
    
    public func intersection(_ other: Self) -> Self {
        Self(elements: elements.intersection(other.elements))
    }
}

extension _SetOfExistentials: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Existential...) {
        self.init(elements)
    }
}

// MARK: - Auxiliary

extension _SetOfExistentials {
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
            lhs.type == rhs.type && AnyEquatable.equate(lhs, rhs)
        }
    }
}
