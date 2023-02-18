//
// Copyright (c) Vatsal Manot
//

import Swift

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

// MARK: - Helpers

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

extension MutableCollection {
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
