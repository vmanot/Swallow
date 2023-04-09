//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _BagOfExistentials<Existential> {
    private var _nonEquatableElements: [Existential] = []
    private var _equatableElements: [_EquatableElement] = []
    private var _hashableElements: Set<_HashableElement> = []
    
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
    
    public var allElements: AnyCollection<Existential> {
        AnyCollection(
            _nonEquatableElements
                ._lazyConcatenate(with: _equatableElements.lazy.map({ $0.value }))
                ._lazyConcatenate(with: _hashableElements.lazy.map({ $0.value }))
        )
    }
    
    public func all<T>(ofType type: T.Type) -> AnyCollection<T> {
        AnyCollection(allElements.lazy.compactMap({ $0 as? T }))
    }
    
    public mutating func insert(_ element: Existential) {
        if let element = _HashableElement(element) {
            _hashableElements.insert(element)
        } else if let element = _EquatableElement(element) {
            _equatableElements.append(element)
        } else {
            _nonEquatableElements.append(element)
        }
    }
    
    public mutating func remove(_ element: Existential) {
        if let element = _HashableElement(element) {
            _hashableElements.remove(element)
        } else if let element = _EquatableElement(element) {
            _equatableElements.removeAll(where: { $0 == element })
        } else {
            fatalError()
        }
    }
    
    public mutating func removeAll(
        where shouldBeRemoved: (Existential) throws -> Bool
    ) rethrows {
        try _nonEquatableElements.removeAll(where: shouldBeRemoved)
        try _equatableElements.removeAll(where: { try shouldBeRemoved($0.value) })
        try _hashableElements.removeAll(where: { try shouldBeRemoved($0.value) })
    }
    
    public func contains(_ element: Existential) -> Bool {
        guard (element is any Equatable) else {
            assertionFailure()
            
            return false
        }
        
        if let element = _HashableElement(element) {
            return _hashableElements.contains(element)
        } else if let element = _EquatableElement(element) {
            return _equatableElements.contains(element)
        } else {
            fatalError()
        }
    }
    
    public func contains<T>(type: T.Type) -> Bool {
        self.contains(where: { _isValueOfGivenType($0, type: type) })
    }
}

// MARK: - Conformances

extension _BagOfExistentials: Sequence {
    public func makeIterator() -> AnyIterator<Existential> {
        allElements.makeIterator()
    }
}

extension _BagOfExistentials {
    public func merge(with other: Self) -> Self {
        Self(AnySequence(self).join(AnySequence(other)))
    }
}

extension _BagOfExistentials: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Existential...) {
        self.init(elements)
    }
}

// MARK: - Auxiliary

extension _BagOfExistentials {
    private struct _EquatableElement: Equatable {
        let value: Existential
        
        private var type: ObjectIdentifier {
            ObjectIdentifier(Swift.type(of: value))
        }
        
        public init?(_ value: Existential) {
            guard value is any Hashable else {
                return nil
            }
            
            self.value = value
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.type == rhs.type && AnyEquatable.equate(lhs, rhs)
        }
    }
    
    private struct _HashableElement: Hashable {
        let value: Existential
        
        private var type: ObjectIdentifier {
            ObjectIdentifier(Swift.type(of: value))
        }
        
        public init?(_ value: Existential) {
            guard value is any Hashable else {
                return nil
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
