//
// Copyright (c) Vatsal Manot
//

import Swift

extension Sequence {
    @_transparent
    public func _mapToSet<T: Hashable>(
        _ transform: (Element) throws -> T
    ) rethrows -> Set<T> {
        var result = Set<T>(minimumCapacity: underestimatedCount)
        
        for element in self {
            try result.insert(transform(element))
        }
        
        return result
    }
    
    @_transparent
    public func _flatMapToSet<T: Hashable>(
        _ transform: (Element) throws -> some Collection<T>
    ) rethrows -> Set<T> {
        var result = Set<T>(minimumCapacity: underestimatedCount)
        
        for element in self {
            for element in try transform(element) {
                result.insert(element)
            }
        }
        
        return result
    }
}

extension Set {
    public func _mapToSet<T: Hashable>(
        _ transform: (Element) throws -> T
    ) rethrows -> Set<T> {
        var result = Set<T>(minimumCapacity: count)
        
        for element in self {
            try result.insert(transform(element))
        }
        
        return result
    }
    
    @_disfavoredOverload
    public func map<T>(
        _ transform: (Element) throws -> T
    ) rethrows -> Set<T> {
        try _mapToSet(transform)
    }
}

extension Set {
    public func intersects(with other: Set) -> Bool {
        !intersection(other).isEmpty
    }
    
    public static func _intersection(
        _ sets: some Collection<Set<Element>>
    ) -> Set<Element> {
        guard !sets.isEmpty else {
            return []
        }
        
        var result = Set(sets.first!)
        
        for set in sets.dropFirst() {
            result = result.intersection(set)
        }
        
        return result
    }
}
