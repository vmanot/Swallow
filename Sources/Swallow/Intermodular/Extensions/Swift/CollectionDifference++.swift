//
// Copyright (c) Vatsal Manot
//

import Swift

extension CollectionDifference {
    public func map<T>(
        _ transform: (ChangeElement) throws -> T
    ) rethrows -> CollectionDifference<T> {
        let insertions = try insertions.map({ try $0.map(transform) })
        let removals = try removals.map({ try $0.map(transform) })
        
        return CollectionDifference<T>(insertions + removals)!
    }
}

// MARK: - Auxiliary

extension CollectionDifference.Change {
    public func map<T>(
        _ transform: (ChangeElement) throws -> T
    ) rethrows -> CollectionDifference<T>.Change {
        switch self {
            case .insert(let offset, let element, let associatedWith):
                return try .insert(
                    offset: offset,
                    element: transform(element),
                    associatedWith: associatedWith
                )
            case .remove(let offset, let element, let associatedWith):
                return try .remove(
                    offset: offset,
                    element: transform(element),
                    associatedWith: associatedWith
                )
        }
    }
}

extension CollectionDifference {
    public struct _Insertion {
        public let offset: Int
        public let element: ChangeElement
        public let associatedWith: Int?
        
        public init(offset: Int, element: ChangeElement, associatedWith: Int?) {
            self.offset = offset
            self.element = element
            self.associatedWith = associatedWith
        }
    }
    
    public struct _Update {
        public let offset: Int
        public let element: ChangeElement
        
        public init(offset: Int, element: ChangeElement) {
            self.offset = offset
            self.element = element
        }
    }

    public struct _Removal {
        public let offset: Int
        public let element: ChangeElement
        public let associatedWith: Int?
        
        public init(offset: Int, element: ChangeElement, associatedWith: Int?) {
            self.offset = offset
            self.element = element
            self.associatedWith = associatedWith
        }
    }
}

extension CollectionDifference.Change {
    public var insertion: CollectionDifference<ChangeElement>._Insertion? {
        if case let .insert(offset, element, associatedWith) = self {
            return .init(offset: offset, element: element, associatedWith: associatedWith)
        }
        
        return nil
    }
        
    public init(_ insertion: CollectionDifference<ChangeElement>._Insertion) {
        self = .insert(
            offset: insertion.offset,
            element: insertion.element,
            associatedWith: insertion.associatedWith
        )
    }
    
    public var removal: CollectionDifference<ChangeElement>._Removal? {
        if case let .remove(offset, element, associatedWith) = self {
            return .init(offset: offset, element: element, associatedWith: associatedWith)
        }
        
        return nil
    }
    
    public init(_ removal: CollectionDifference<ChangeElement>._Removal) {
        self = .remove(
            offset: removal.offset,
            element: removal.element,
            associatedWith: removal.associatedWith
        )
    }
}

extension CollectionDifference {
    public var _insertions: [_Insertion] {
        insertions.compactMap { (change: Change) -> _Insertion? in
            guard let insertion = change.insertion else {
                assertionFailure()
                
                return nil
            }
            
            return insertion
        }
    }
    
    public var _removals: [_Removal] {
        removals.compactMap { (change: Change) -> _Removal? in
            guard let removal = change.removal else {
                assertionFailure()
                
                return nil
            }
            
            return removal
        }
    }
}
