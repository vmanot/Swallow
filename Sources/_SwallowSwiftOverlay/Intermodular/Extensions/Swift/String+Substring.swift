//
// Copyright (c) Vatsal Manot
//

import Swift

extension String {    
    public subscript(
        firstSubstring substring: String
    ) -> Substring? {
        range(of: substring).map({ self[$0] })
    }
    
    public func substrings(
        separatedBy separator: Character
    ) -> [Substring] {
        split(whereSeparator: { $0 == separator })
    }
}

extension String {
    @_disfavoredOverload
    public func dropFirst() -> Substring {
        self.dropFirst(1)
    }
    
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Substring {
        hasPrefix(prefix) ? dropFirst(prefix.count) : .init(self)
    }
    
    @_disfavoredOverload
    public func dropPresentPrefix<String: StringProtocol>(_ prefix: String) -> Substring? {
        hasPrefix(prefix) ? dropFirst(prefix.count) : nil
    }
    
    @_disfavoredOverload
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Self {
        Self(dropPrefixIfPresent(prefix) as Substring)
    }
    
    @_disfavoredOverload
    public func dropPresentPrefix<String: StringProtocol>(_ prefix: String) -> Self? {
        (dropPresentPrefix(prefix) as Substring?).map({ Self($0) })
    }
    
    public func addingPrefixIfMissing(_ prefix: String) -> String {
        hasPrefix(prefix) ? self : (prefix + self)
    }
    
    @_disfavoredOverload
    public func dropLast() -> Substring {
        return dropLast(1)
    }
    
    public func dropSuffixIfPresent<String: StringProtocol>(_ suffix: String) -> Substring {
        return hasSuffix(suffix) ? dropLast(suffix.count) : .init(self)
    }
    
    @_disfavoredOverload
    public func dropSuffixIfPresent<String: StringProtocol>(_ prefix: String) -> Self {
        Self(dropSuffixIfPresent(prefix) as Substring)
    }
    
    public func addingSuffixIfMissing(_ suffix: String) -> String {
        hasSuffix(suffix) ? self : (self + suffix)
    }
}

extension Substring {
    public func dropFirst() -> Substring {
        dropFirst(1)
    }
    
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Substring {
        hasPrefix(prefix) ? dropFirst(prefix.count) : self
    }
    
    public func dropLast() -> Substring {
        dropLast(1)
    }
    
    public func dropSuffixIfPresent<String: StringProtocol>(_ suffix: String) -> Substring {
        hasSuffix(suffix) ? dropLast(suffix.count) : self
    }
}
