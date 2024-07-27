//
// Copyright (c) Vatsal Manot
//

import Swallow

public enum LinkedList<Element>: Initiable {
    indirect case node(head: Element, tail: LinkedList)
    
    case none
    
    public init(head: Element, tail: LinkedList) {
        self = .node(head: head, tail: tail)
    }
    
    public init() {
        self = .none
    }
}

// MARK: - Extensions

extension LinkedList {
    public var decompose: (head: Element, tail: LinkedList)? {
        get {
            if case .node(let head, let tail) = self {
                return (head, tail)
            }
            
            return nil
        } set {
            if let newValue = newValue {
                self = .init(head: newValue.head, tail: newValue.tail)
            }
            
            else {
                self = .none
            }
        }
    }
    
    public var head: Element? {
        get {
            return decompose?.head
        } set {
            decompose = newValue.map({ x in decompose.map({ (x, $1) }) ?? (x, []) }) ?? tail.decompose
        }
    }
    
    public var tail: LinkedList {
        get {
            return decompose?.tail ?? .none
        } set {
            decompose?.tail = newValue
        }
    }
}

// MARK: - Conformances

extension LinkedList: CustomStringConvertible {
    public var description: String {
        return Array(self).description
    }
}

extension LinkedList: Collection {
    public typealias Index = Int
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        var count = 0
        var iterator = makeIterator()
        
        while iterator.next() != nil {
            count += 1
        }
        
        return count
    }
    
    public var isEmpty: Bool {
        if case .none = self {
            return true
        }
        
        return false
    }
    
    public subscript(index: Index) -> Element {
        get {
            var iterator = makeIterator()
            
            _ = iterator.exhaust(count: index)
            
            return try! iterator.next().forceUnwrap()
        }
    }
}

extension LinkedList: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        self.init()
        
        while !container.isAtEnd {
            append(try container.decode(Element.self))
        }
    }
}

extension LinkedList: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        for element in self {
            try container.encode(element)
        }
    }
}

extension LinkedList: Equatable where Element: Equatable {
    
}

extension LinkedList: ExtensibleSequence {
    public mutating func insert(_ newElement: Element) {
        self = .node(head: newElement, tail: self)
    }
    
    public mutating func append(_ newElement: Element) {
        append(contentsOf: CollectionOfOne(newElement))
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        self = .init(self.join(newElements))
    }
}

extension LinkedList: Hashable where Element: Hashable {
    
}

extension LinkedList: IteratorProtocol {
    public mutating func next() -> Element? {
        guard let (head, tail) = decompose else {
            return nil
        }
        
        self = tail
        return head
    }
}

extension LinkedList: Sequence {
    public struct Iterator: IteratorProtocol, Wrapper {
        public typealias Value = LinkedList<Element>
        
        public var value: Value
        
        public init(_ value: Value) {
            self.value = value
        }
        
        public mutating func next() -> Element? {
            defer {
                if !value.isEmpty {
                    value = value.decompose!.tail
                }
            }
            
            return value.decompose?.head
        }
    }
    
    public func makeIterator() -> Iterator {
        .init(self)
    }
}

extension LinkedList: SequenceInitiableSequence, ExpressibleByArrayLiteral {
    public init<S: Sequence>(_ source: S) where S.Element == Element {
        self = source.reversed().reduce(.none, { $0.inserting($1) })
    }
}
