//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnyBidirectionalCollection: AnyBidirectionalCollectionType {
    public func eraseToAnyBidirectionalCollection() -> AnyBidirectionalCollection<Element> {
        .init(self)
    }
}

extension Collection {
    public func eraseToAnyCollection() -> AnyCollection<Element> {
        .init(self)
    }
}

extension BidirectionalCollection {
    public func eraseToAnyBidirectionalCollection() -> AnyBidirectionalCollection<Element> {
        .init(self)
    }
}

extension RandomAccessCollection {
    public func eraseToAnyRandomAccessCollection() -> AnyRandomAccessCollection<Element> {
        .init(self)
    }
}

extension Collection {
    public func toCollectionOfOne() throws -> CollectionOfOne<Element> {
        switch count {
            case 0:
                throw CollectionOfOneConversionError<Self>.isEmpty
            case 1:
                return .init(first!)
            default:
                throw CollectionOfOneConversionError<Self>.containsMoreThanOneElement(self)
        }
    }
    
    public func toCollectionOfZeroOrOne() throws -> CollectionOfOne<Element>? {
        guard !isEmpty else {
            return nil
        }
        
        return try toCollectionOfOne()
    }
}

extension Collection {
    public subscript(_ index: RelativeIndex) -> Element {
        return self[self.index(atDistance: index.distanceFromStartIndex)]
    }
    
    public subscript(_ index: FirstOrLastCollectionIndex) -> Element {
        switch index {
            case .first:
                return first!
            case .last:
                return last!
        }
    }
}

extension MutableCollection where Indices: Collection {
    public subscript(_ index: RelativeIndex) -> Element {
        get {
            lazy.map({ $0 })[index]
        } set {
            self[self.index(atDistance: index.distanceFromStartIndex)] = newValue
        }
    }
    
    public subscript(_ index: FirstOrLastCollectionIndex) -> Element {
        get {
            return lazy.map({ $0 })[index]
        } set {
            switch index {
                case .first:
                    self[indices.first!] = newValue
                case .last:
                    self[indices.last!] = newValue
            }
        }
    }
}

// MARK: - Auxiliary

public protocol AnyBidirectionalCollectionType<Element>: BidirectionalCollection where Index == AnyBidirectionalCollection<Element>.Index {
    init<C: BidirectionalCollection>(_ collection: C) where C.Element == Element
    init(_ collection: AnyBidirectionalCollection<Element>)
    
    func eraseToAnyBidirectionalCollection() -> AnyBidirectionalCollection<Element>
}

public enum FirstOrLastCollectionIndex {
    case first
    case last
}

public struct RelativeIndex: ExpressibleByIntegerLiteral {
    public let distanceFromStartIndex: Int
    
    public init(atDistance distance: Int) {
        self.distanceFromStartIndex = distance
    }
    
    public static func atDistance(_ distance: Int) -> RelativeIndex {
        return .init(atDistance: distance)
    }
    
    public init<C: Collection>(_ index: C.Index, in collection: C) {
        self.init(atDistance: collection.distance(from: collection.startIndex, to: index))
    }
    
    public init(integerLiteral value: Int) {
        self.distanceFromStartIndex = value
    }
    
    public func absolute<C: Collection>(in collection: C) -> C.Index {
        return collection.index(atDistance: distanceFromStartIndex)
    }
}

// MARK: - Error Handling


private enum CollectionOfOneConversionError<Base: Collection>: Swift.Error {
    case isEmpty
    case containsMoreThanOneElement(Base)
}
