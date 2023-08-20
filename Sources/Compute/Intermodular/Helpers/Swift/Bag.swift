//
// Copyright (c) Vatsal Manot
//

import Swallow

protocol BagType: Sequence {
    associatedtype ElementKey
    
    mutating func insert(_ element: Element) -> ElementKey
    mutating func removeElement(forKey _: ElementKey) -> Element?
}

public struct Bag<Element>: BagType {
    public struct Key: Equatable, Hashable {
        fileprivate let rawValue: UInt64
    }
    
    public typealias KeyType = Key
    public typealias Entry = (key: Key, value: Element)
    
    fileprivate let arrayDictionaryMaxSize = 30
    
    private var nextKey = Key(rawValue: 0)
    private var key0: Key?
    private var value0: Element?
    private var pairs = ContiguousArray<Entry>()
    private var dictionary: [Key: Element]?
    private var onlyFastPath = true
    
    public init() {
        
    }
    
    public var count: Int {
        let dictionaryCount = dictionary?.count ?? 0
        
        return 0
            + (value0 != nil ? 1 : 0)
            + pairs.count
            + dictionaryCount
    }
    
    public mutating func insert(_ element: Element) -> Key {
        let key = nextKey
        
        nextKey = Key(rawValue: nextKey.rawValue &+ 1)
        
        if key0 == nil {
            key0 = key
            value0 = element
            return key
        }
        
        onlyFastPath = false
        
        if dictionary != nil {
            dictionary![key] = element
            return key
        }
        
        if pairs.count < arrayDictionaryMaxSize {
            pairs.append((key: key, value: element))
            return key
        }
        
        dictionary = [key: element]
        
        return key
    }
    
    public mutating func removeElement(forKey key: Key) -> Element? {
        if key0 == key {
            key0 = nil
            let value = value0!
            value0 = nil
            return value
        }
        
        if let existingObject = dictionary?.removeValue(forKey: key) {
            return existingObject
        }
        
        for i in 0..<pairs.count {
            if pairs[i].key == key {
                let value = pairs[i].value
                pairs.remove(at: i)
                return value
            }
        }
        
        return nil
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        key0 = nil
        value0 = nil
        
        pairs.removeAll(keepingCapacity: keepingCapacity)
        dictionary?.removeAll(keepingCapacity: keepingCapacity)
    }
}

// MARK: - Conformances

extension Bag: CustomDebugStringConvertible {
    public var debugDescription : String {
        Array(self).debugDescription
    }
}

extension Bag: Sequence {
    public func forEach(
        _ action: ((Element) throws -> Void)
    ) rethrows {
        try value0.map(action)
        
        guard !onlyFastPath else {
            return
        }
        
        try pairs.forEach({ try action($0.value )})
        try dictionary?.values.forEach(action)
    }
    
    public mutating func _forEach(
        mutating action: ((inout Element) throws -> Void)
    ) rethrows {
        try value0.mutate(action)
        
        guard !onlyFastPath else {
            return
        }
        
        try pairs._forEach(mutating: { try action(&$0.value )})
        try dictionary?._forEach(mutating: { try action(&$0.value) })
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        if let value0 = value0 {
            let value0Collection = CollectionOfOne(value0)
            if onlyFastPath {
                return .init(value0Collection.makeIterator())
            }
            if pairs.count > 0 {
                let pairsValues = pairs.lazy.map { $0.value }
                if let dictionary = dictionary, dictionary.count > 0 {
                    let dictionaryValues = dictionary.values
                    return .init(
                        value0Collection
                            .join(pairsValues)
                            .join(dictionaryValues)
                            .makeIterator()
                    )
                } else {
                    return .init(value0Collection.join(pairsValues).makeIterator())
                }
            } else {
                return .init(value0Collection.makeIterator())
            }
        } else {
            return .init(EmptyCollection<Element>().makeIterator())
        }
    }
}
