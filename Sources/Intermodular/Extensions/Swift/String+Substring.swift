//
// Copyright (c) Vatsal Manot
//

import Swift

extension String {
    public func contains(substring: Substring) -> Bool {
        return substring.parent == self && bounds.contains(substring.bounds)
    }
    
    public func contains(substring: Substring?) -> Bool {
        return substring.map({ contains(substring: $0) }) ?? false
    }
    
    public subscript(firstSubstring substring: String) -> Substring? {
        return range(of: substring).map({ self[$0] })
    }
    
    public func substrings(separatedBy separator: Character) -> [Substring] {
        return split(whereSeparator: { $0 == separator })
    }
    
    public func lines() -> [Substring] {
        TODO.whole(.addressEdgeCase, .optimize, note: "Address \"\r\\n\" because Microsoft fucking Windows")
        
        return substrings(separatedBy: Character.newLine)
    }
    
    public func line(containingSubstring substring: Substring) -> Substring? {
        TODO.below(.optimize)
        
        return lines().find({ $0.contains(substring: substring) })
    }
}

extension String {
    public func dropFirst() -> Substring {
        return dropFirst(1)
    }
    
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Substring {
        hasPrefix(prefix) ? dropFirst(prefix.count) : .init(self)
    }
    
    #if swift(>=5.3)
    @_disfavoredOverload
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Self {
        Self(dropPrefixIfPresent(prefix) as Substring)
    }
    #endif
    
    public func dropLast() -> Substring {
        return dropLast(1)
    }
    
    public func dropSuffixIfPresent<String: StringProtocol>(_ suffix: String) -> Substring {
        return hasSuffix(suffix) ? dropLast(suffix.count) : .init(self)
    }
    
    #if swift(>=5.3)
    @_disfavoredOverload
    public func dropSuffixIfPresent<String: StringProtocol>(_ prefix: String) -> Self {
        Self(dropSuffixIfPresent(prefix) as Substring)
    }
    #endif
}

extension Substring {
    public func dropFirst() -> Substring {
        return dropFirst(1)
    }
    
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Substring {
        return hasPrefix(prefix) ? dropFirst(prefix.count) : .init(self)
    }
    
    public func dropLast() -> Substring {
        return dropLast(1)
    }
    
    public func dropSuffixIfPresent<String: StringProtocol>(_ suffix: String) -> Substring {
        return hasSuffix(suffix) ? dropLast(suffix.count) : .init(self)
    }
}