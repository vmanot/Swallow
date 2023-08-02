//
// Copyright (c) Vatsal Manot
//

import Swift

extension String {
    public func contains(substring: Substring?) -> Bool {
        return substring.map({ contains(substring: $0) }) ?? false
    }
    
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
    
    public var numberOfLines: Int {
        var result = 0
        
        enumerateLines { (_, _) in
            result += 1
        }
        
        return result
    }
    
    public func lines(omittingEmpty: Bool = false) -> [Substring] {
        split(omittingEmptySubsequences: false, whereSeparator: { $0 == Character.newline })
    }
    
    public func enumeratedLines() -> [String] {
        var result: [String] = []
        
        enumerateLines(invoking: { line, _ in
            result.append(line)
        })
        
        return result
    }
    
    public func line(containingSubstring substring: Substring) -> Substring? {
        TODO.whole(.optimize)
        
        return lines().find({ $0.contains(substring) })
    }
}

extension String {
    public func dropFirst() -> Substring {
        self.dropFirst(1)
    }
    
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Substring {
        hasPrefix(prefix) ? dropFirst(prefix.count) : .init(self)
    }
    
    @_disfavoredOverload
    public func dropPrefixIfPresent<String: StringProtocol>(_ prefix: String) -> Self {
        Self(dropPrefixIfPresent(prefix) as Substring)
    }
    
    public func addingPrefixIfMissing(_ prefix: String) -> String {
        hasPrefix(prefix) ? self : (prefix + self)
    }
    
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
