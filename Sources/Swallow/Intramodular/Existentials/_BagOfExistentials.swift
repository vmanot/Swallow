//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _BagOfExistentials<Existential>: @unchecked Sendable {
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
    
    public var count: Int {
        allElements.count
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
    
    public mutating func insert(
        contentsOf elements: some Sequence<Existential>
    ) {
        for element in elements {
            insert(element)
        }
    }
    
    public func inserting(_ element: Existential) -> Self {
        build(self, with: { $0.insert(element) })
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
    
    /// Removes all the elements that satisfy the given predicate.
    public mutating func removeAll(
        where shouldBeRemoved: (Existential) throws -> Bool
    ) rethrows {
        try _nonEquatableElements.removeAll(where: shouldBeRemoved)
        try _equatableElements.removeAll(where: { try shouldBeRemoved($0.value) })
        try _hashableElements.removeAll(where: { try shouldBeRemoved($0.value) })
    }
    
    /// Removes all elements from the bag.
    public mutating func removeAll() {
        _nonEquatableElements.removeAll()
        _equatableElements.removeAll()
        _hashableElements.removeAll()
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
    
    public func first<T>(ofType type: T.Type) -> T? {
        self.first(where: { _isValueOfGivenType($0, type: type) }).map({ $0 as! T })
    }
    
    @_disfavoredOverload
    public func first(
        ofType type: Any.Type
    ) -> Any? {
        self.first(where: { _isValueOfGivenType($0, type: type) }).map({ $0 as Any })
    }
    
    public func firstAndOnly<T>(
        ofType type: T.Type
    ) throws -> T? {
        try self.filter({ _isValueOfGivenType($0, type: type) }).firstAndOnly(ofType: type)
    }
    
    public mutating func removeAll<T>(
        ofType type: T.Type
    ) {
        removeAll(where: { _isValueOfGivenType($0, type: type) })
    }

    public mutating func removeAll(
        ofType type: Any.Type
    ) {
        removeAll(where: { _isValueOfGivenType($0, type: type) })
    }
    
    public mutating func replaceAll<T>(
        ofType type: T.Type,
        with element: Existential
    ) {
        removeAll(ofType: type)
        
        insert(element)
    }
}

// MARK: - Conformances

extension _BagOfExistentials: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        Array(self).debugDescription
    }
    
    public var description: String {
        Array(self).description
    }
}

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
            lhs.type == rhs.type && AnyEquatable.equate(lhs.value, rhs.value)
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
            lhs.type == rhs.type && AnyEquatable.equate(lhs.value, rhs.value)
        }
    }
}
