//
// Copyright (c) Vatsal Manot
//

import Swift

extension Optional {
    public func map<T>(keyPath: KeyPath<Wrapped, T>) -> T? {
        return map({ $0[keyPath: keyPath] })
    }
    
    public func flatMap<T>(keyPath: KeyPath<Wrapped, T?>) -> T? {
        return flatMap({ $0[keyPath: keyPath] })
    }
}

extension Sequence {
    public func map<T>(keyPath: KeyPath<Element, T>) -> [T] {
        return map({ $0[keyPath: keyPath] })
    }
}

extension LazySequence {
    public func map<T>(keyPath: KeyPath<Element, T>) -> LazyMapSequence<Base, T> {
        return map({ $0[keyPath: keyPath] })
    }
}
