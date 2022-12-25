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

// MARK: - Auxiliary -

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
