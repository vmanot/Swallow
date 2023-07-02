//
// Copyright (c) Vatsal Manot
//

import Swift

extension Hasher {
    @inlinable
    public static func finalizedHashValue<T: Hashable>(for value: T) -> Int {
        var hasher = Hasher()
        
        hasher.combine(value)
        
        return hasher.finalize()
    }
    
    @inlinable
    public static func finalizedHashValue<T: Hashable, U: Hashable>(combining first: T, _ second: U) -> Int {
        var hasher = Hasher()
        
        hasher.combine(first)
        hasher.combine(second)
        
        return hasher.finalize()
    }
    
    @inlinable
    public static func finalizedHashValue<T: Hashable, U: Hashable, V: Hashable>(combining first: T, _ second: U, _ third: V) -> Int {
        var hasher = Hasher()
        
        hasher.combine(first)
        hasher.combine(second)
        hasher.combine(third)
        
        return hasher.finalize()
    }
    
    @inlinable
    public static func finalizedHashValue<T: Hashable, U: Hashable, V: Hashable, W: Hashable>(combining first: T, _ second: U, _ third: V, _ fourth: W) -> Int {
        var hasher = Hasher()
        
        hasher.combine(first)
        hasher.combine(second)
        hasher.combine(third)
        hasher.combine(fourth)
        
        return hasher.finalize()
    }
    
    @inlinable
    public static func finalizedHashValue<S: Sequence>(combiningContentsOf sequence: S) -> Int where S.Element: Hashable {
        var hasher = Hasher()
        
        sequence.forEach({ hasher.combine($0) })
        
        return hasher.finalize()
    }
    
    @inlinable
    public static func finalizedHashValue<S: Sequence>(combiningContentsOf sequence: S) -> Int where S.Element == AnyHashable {
        var hasher = Hasher()
        
        sequence.forEach({ hasher.combine($0) })
        
        return hasher.finalize()
    }
    
    @inlinable
    public static func finalizedHashValue<S: Sequence>(combiningUnorderedContentsOf sequence: S) -> Int where S.Element: Hashable {
        var hasher = Hasher()
        
        hasher.combine(Set(sequence.lazy.map(keyPath: \.hashValue)))
        
        return hasher.finalize()
    }
}
