//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A bidirectional map between two `Hashable` types.
public struct BidirectionalMap<Left: Hashable, Right: Hashable>: NonDestroyingCollection, Initiable, SequenceInitiableSequence {
    fileprivate var base: Pair<[Left: Right], [Right: Left]>
    
    public var nonDestructiveCount: Int {
        base.value.0.count
    }
    
    public init() {
        self.base = .init()
    }
    
    public init<S: Sequence>(_ value: S) where S.Element == Element {
        self.init()
        
        self.base.value.0 = .init(value)
        self.base.value.1 = .init(value.lazy.map({ ($1, $0) }))
    }
}

// MARK: - Extensions

extension BidirectionalMap {
    public typealias LeftValues = Dictionary<Left, Right>.Keys
    public typealias RightValues = Dictionary<Left, Right>.Values
    
    public var leftValues: LeftValues {
        base.value.0.keys
    }
    
    public var rightValues: RightValues {
        base.value.0.values
    }
    
    @discardableResult
    public mutating func associate(_ left: Left, _ right: Right) -> (Right?, Left?) {
        (base.value.0.updateValue(right, forKey: left), base.value.1.updateValue(left, forKey: right))
    }
    
    @discardableResult
    public mutating func disassociate(left: Left) -> Right? {
        guard let right = base.value.0.removeValue(forKey: left) else {
            return nil
        }
        
        base.value.1.removeValue(forKey: right)
        
        return right
    }
    
    @discardableResult
    public mutating func disassociate(right: Right) -> Left? {
        guard let left = base.value.1.removeValue(forKey: right) else {
            return nil
        }
        
        base.value.0.removeValue(forKey: left)
        
        return left
    }
    
    public mutating func disassociateAll(keepCapacity: Bool = false) {
        base.value.0.removeAll(keepingCapacity: keepCapacity)
        base.value.1.removeAll(keepingCapacity: keepCapacity)
    }
}

extension BidirectionalMap {
    public subscript(left left: Left) -> Right? {
        get {
            return base.value.0[left]
        } set {
            if let newValue = newValue {
                associate(left, newValue)
            } else {
                disassociate(left: left)
            }
        }
    }
    
    public subscript(right right: Right) -> Left? {
        get {
            base.value.1[right]
        } set {
            if let newValue = newValue {
                associate(newValue, right)
            } else {
                disassociate(right: right)
            }
        }
    }
    
    public subscript(left: Left) -> Right? {
        get {
            self[left: left]
        } set {
            self[left: left] = newValue
        }
    }
    
    public subscript(right: Right) -> Left? {
        get {
            self[right: right]
        } set {
            self[right: right] = newValue
        }
    }
}

extension BidirectionalMap {
    public func index(forLeft value: Left) -> Index? {
        base.value.0.index(forKey: value)
    }
    
    public func index(forValue value: Left) -> Index? {
        index(forLeft: value)
    }
    
    public func index(forRight value: Right) -> Index? {
        guard let value = self[right: value] else {
            return nil
        }
        
        return index(forLeft: value)
    }
    
    public func index(forValue value: Right) -> Index? {
        index(forRight: value)
    }
    
    public func index(forValue value: Either<Left, Right>) -> Index? {
        value.reduce(index(forLeft:), index(forRight:))
    }
    
    @discardableResult
    public mutating func disassociate(atIndex index: Index) -> (Left, Right) {
        let (left, right) = base.value.0.remove(at: index)
        
        base.value.1.removeValue(forKey: right)
        
        return (left, right)
    }
}

// MARK: - Conformances

extension BidirectionalMap: Collection {
    public typealias Index = Dictionary<Left, Right>.Index
    
    public var startIndex: Index {
        base.value.0.startIndex
    }
    
    public var endIndex: Index {
        base.value.0.endIndex
    }
    
    public subscript(position: Index) -> Element {
        base.value.0[position]
    }
    
    public subscript(bounds: Range<Dictionary<Left, Right>.Index>) -> Dictionary<Left, Right>.SubSequence {
        base.value.0[bounds]
    }
    
    public func index(after i: Index) -> Index {
        base.value.0.index(after: i)
    }
}

extension BidirectionalMap: CustomStringConvertible {
    public var description: String {
        base.value.0.description
    }
}

extension BidirectionalMap: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Left, Right)...) {
        self.init(elements)
    }
}

extension BidirectionalMap: KeyExposingMutableDictionaryProtocol {
    public typealias DictionaryKey = Left
    public typealias DictionaryValue = Right
    
    public var keys: Dictionary<Left, Right>.Keys {
        base.value.0.keys
    }
    
    public var values: Dictionary<Left, Right>.Values {
        base.value.0.values
    }
    
    public var keysAndValues: Dictionary<Left, Right> {
        base.value.0
    }
    
    public func key(forValue value: Right) -> Left? {
        self[right: value]
    }
    
    public mutating func setValue(_ value: Right, forKey key: Left) {
        self[key] = value
    }
}

extension BidirectionalMap: ElementRemoveableDestructivelyMutableSequence {
    public typealias Element = Dictionary<Left, Right>.Element
    public typealias Iterator = Dictionary<Left, Right>.Iterator
    public typealias SubSequence = Dictionary<Left, Right>.SubSequence
    
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        let first = base.value.1.removeValue(forKey: element.1)
        let second = base.value.0.removeValue(forKey: element.0)
        
        if let first = first, let second = second {
            return (first, second)
        } else if first == nil && second == nil {
            return nil
        } else {
            assertionFailure()
            
            return nil
        }
    }
    
    public mutating func _forEach<T>(
        mutating body: ((inout Element) throws -> T)
    ) rethrows {
        for (key, value) in self {
            var keyValuePair: Element = (key, value)
            
            _ = try body(&keyValuePair)
            
            self[keyValuePair.0] = keyValuePair.1
        }
    }
    
    public mutating func _forEach<T>(
        destructivelyMutating iterator: ((inout Element?) throws -> T)
    ) rethrows {
        for element in self {
            var _element: Element! = element
            
            _ = try iterator(&_element)
            
            if _element == nil {
                remove(element)
            } else {
                self[_element.0] = _element.1
            }
        }
    }
    
    public mutating func removeAll(where predicate: ((Element) throws -> Bool)) rethrows {        
        try _removeAll(where: predicate)
    }
    
    public func makeIterator() -> Dictionary<Left, Right>.Iterator {
        base.value.0.makeIterator()
    }
}

// MARK: - Conformances

extension BidirectionalMap: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base.value.0)
    }
}

extension BidirectionalMap: Equatable {
    public static func == (lhs: BidirectionalMap, rhs: BidirectionalMap) -> Bool {
        lhs.base.value.0 == rhs.base.value.0
    }
}

// MARK: - Conditional Conformances

extension BidirectionalMap: Codable where Left: Codable, Right: Codable {
    public init(from decoder: Decoder) throws {
        let data: [Left: Right] = try .init(from: decoder)
        
        self.init(data)
    }
    
    public func encode(to encoder: Encoder) throws {
        let data: [Left: Right] = base.value.0
        
        try data.encode(to: encoder)
    }
}

extension BidirectionalMap: Sendable where Left: Sendable, Right: Sendable {
    
}
