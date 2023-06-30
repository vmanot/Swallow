//
// Copyright (c) Vatsal Manot
//

import Swift

extension Set {
    public func intersects(with other: Set) -> Bool {
        !intersection(other).isEmpty
    }
}

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
