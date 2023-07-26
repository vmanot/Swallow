//
// Copyright (c) Vatsal Manot
//

import Swift

extension Set {
    public func _mapToSet<T>(
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
    
    static func _intersection(
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
