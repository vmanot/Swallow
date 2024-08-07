//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Dispatch
import Swift

extension Collection {
    @_transparent
    public func _dispatch_concurrentFlatMap<T>(
        _ transform: (Element) -> some Sequence<T>
    ) -> [T] {
        _dispatch_concurrentMap(transform).flatMap({ $0 })
    }
    
    @_transparent
    public func _dispatch_concurrentCompactMap<T>(
        _ transform: (Element) -> T?
    ) -> [T] {
        _dispatch_concurrentMap(transform).compactMap({ $0 })
    }
    
    @_transparent
    public func _dispatch_concurrentFilter(
        _ predicate: (Element) -> Bool
    ) -> [Element] {
        _dispatch_concurrentMap({ predicate($0) ? $0 : nil }).compactMap({ $0 })
    }
        
    @_transparent
    public func _dispatch_concurrentPerform(
        _ transform: (Element) -> Void
    ) {
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            transform(self[atDistance: idx])
        }
    }
}

extension Set {
    @_transparent
    public func _dispatch_concurrentCompactMap<T>(
        _ transform: (Element) -> T?
    ) -> Set<T> {
        return _dispatch_concurrentMap(transform).compactMap({ $0 })
    }
    
    @_transparent
    public func _dispatch_concurrentFilter(
        _ predicate: (Element) -> Bool
    ) -> Set<Element> {
        return _dispatch_concurrentMap({ predicate($0) ? $0 : nil }).compactMap({ $0 })
    }
    
    @_transparent
    public func compactMap<ElementOfResult: Hashable>(
        _ transform: (Element) throws -> ElementOfResult?
    ) rethrows -> Set<ElementOfResult> {
        try Set<ElementOfResult>(self.lazy.compactMap(transform))
    }
}

#if swift(>=6.0)
extension Sequence {
    @_transparent
    public func _dispatch_concurrentMap<T>(
        _ transform: (Element) -> T
    ) -> [T] {
        var result = ContiguousArray<T?>(repeating: nil, count: count)
        return result.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: buffer.count) { idx in
                buffer[idx] = transform(self[atDistance: idx])
            }
            return buffer.map({ $0! })
        }
    }

    @_transparent
    public func _dispatch_concurrentMap<T>(
        _ transform: (Element) -> T
    ) -> Set<T> {
        var result = ContiguousArray<T?>(repeating: nil, count: count)
        return result.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: buffer.count) { idx in
                buffer[idx] = transform(self[atDistance: idx])
            }
            return buffer._mapToSet({ $0! })
        }
    }
}
#else
extension Sequence {
    @_transparent
    public func _dispatch_concurrentMap<T>(
        _ transform: (Element) -> T
    ) -> [T] {
        map(transform)
    }
    
    @_transparent
    public func _dispatch_concurrentMap<T>(
        _ transform: (Element) -> T
    ) -> Set<T> {
        Set(map(transform))
    }
}
#endif
