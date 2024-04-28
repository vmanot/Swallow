//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Swift

extension Sequence {
    public func interspersed(
        with separator: Element
    ) -> AnyRandomAccessCollection<Element> {
        guard let first = first else {
            return AnyRandomAccessCollection(EmptyCollection())
        }
        
        return AnyRandomAccessCollection(
            CollectionOfOne(first).join(
                self.dropFirst().flatMap {
                    CollectionOfOne(separator).join(CollectionOfOne($0))
                }
            )
        )
    }
    
    public func interspersed(
        with separator: Element,
        where shouldSeparate: (Element) -> Bool
    ) -> AnyRandomAccessCollection<Element> {
        guard let first = first else {
            return AnyRandomAccessCollection(EmptyCollection())
        }
        
        return AnyRandomAccessCollection(
            CollectionOfOne(first).join(
                self.dropFirst().flatMap { element in
                    if shouldSeparate(element) {
                        return CollectionOfOne(separator).join(CollectionOfOne(element)).eraseToAnyRandomAccessCollection()
                    } else {
                        return CollectionOfOne(element).eraseToAnyRandomAccessCollection()
                    }
                }
            )
        )
    }
}

extension Sequence {
    @_disfavoredOverload
    public mutating func removeFirst<T>(
        byUnwrapping transform: (Element) throws -> T?
    ) rethrows -> T? where Self: DestructivelyMutableSequence {
        var result: T?
        
        try self.removeAll(where: { (element: Element) in
            guard let _result = try transform(element) else {
                return false
            }
            
            if result == nil {
                result = _result
                
                return true
            } else {
                return false
            }
        })
        
        return result
    }
    
    @_disfavoredOverload
    public mutating func removeFirstAndOnly<T>(
        byUnwrapping transform: (Element) throws -> T?
    ) throws -> T? where Self: DestructivelyMutableSequence {
        var result: T?
        
        try self.removeAll(where: { (element: Element) in
            guard let transformedElement = try transform(element) else {
                return false
            }
            
            if result == nil {
                result = transformedElement
                
                return true
            } else {
                throw SequenceFirstAndOnlyError<Self>.foundAnother(element)
            }
        })
        
        return result
    }
}

extension Sequence {
    public func _filter(
        removingInto filtered: inout [Element],
        _ predicate: (Element) throws -> Bool
    ) rethrows -> IdentifierIndexingArrayOf<Element> where Element: Identifiable {
        var result: IdentifierIndexingArrayOf<Element> = []
        
        for element in self {
            if try predicate(element) {
                result.append(element)
            } else {
                filtered.append(element)
            }
        }
        
        return result
    }
}

extension Sequence {
    @inlinable
    public func find<T: Boolean>(
        _ predicate: ((Element) throws -> T)
    ) rethrows -> Element? {
        try find({ take, element in try predicate(element) &&-> take(element) })
    }
}

extension Sequence {
    public func map<T>(
        _ f: (@escaping (Element) -> T),
        everyOther g: (@escaping (Element) -> T)
    ) -> LazyMapSequenceWithMemoryRecall<Self, Bool, T> {
        return LazyMapSequenceWithMemoryRecall(
            base: self,
            initial: false,
            transform: { $0 = !$0; return $0 ? f($1) : g($1) }
        )
    }
}
