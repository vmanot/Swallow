//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension RegularExpression {
    public func capture(
        _ target: Target,
        named name: String? = nil,
        options: Options = []
    ) -> Self {
        capture(RegularExpression().match(target), named: name, options: options)
    }
    
    public func capture(
        _ expression: Self,
        named name: String? = nil,
        options: Options = []
    ) -> Self {
        self + expression.captureGroup(named: name).options(options)
    }
    
    public func capture(
        _ name: String? = nil,
        options: Options = [],
        _ closure: () -> Self
    ) -> Self {
        capture(closure(), named: name, options: options)
    }
    
    public func capture(
        _ name: String? = nil,
        options: Options = [],
        _ closure: (Self) -> Self
    ) -> Self {
        capture(closure(.init()), named: name, options: options)
    }
}

extension RegularExpression {
    public func captureRanges(
        in string: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> [[Range<String.Index>?]] {
        var matches: [[Range<String.Index>?]] = []
        
        (self as NSRegularExpression).enumerateMatches(in: string, options: options, range: NSRange(string.bounds, in: string)) { result, flags, stop in
            if let result = result {
                matches.append(result.ranges(in: string))
            }
        }
        
        return matches
    }
    
    public func captureGroups(
        in string: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> [[Substring?]] {
        captureRanges(in: string, options: options).map({ $0.map({ $0.map({ string[$0] }) }) })
    }
    
    public func captureFirstRanges(
        in string: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> [Range<String.Index>?] {
        (self as NSRegularExpression).firstMatch(in: string, options: options, range: NSRange(string.bounds, in: string))?.ranges(in: string) ?? []
    }
    
    public func captureFirstGroups(
        in string: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> [Substring?] {
        captureFirstRanges(in: string, options: options).map({ $0.map({ string[$0] }) })
    }
    
    public func captureNamedGroups(
        in string: String,
        options: NSRegularExpression.MatchingOptions = [],
        range: NSRange? = nil
    ) -> [String: [Substring]] {
        let range = range ?? NSRange(location: 0, length: string.utf16.count)
        let regex = self as NSRegularExpression
        let names = regex.textCheckingResultsOfNamedCaptureGroups()
        
        var result = [String: [Substring]]()
        let matches = regex.matches(in: string, options: options, range: range)
        
        for (_, matchResult) in matches.enumerated() {
            let substrings = matchResult.substrings(in: string).compact()
            
            for (index, substring) in substrings.enumerated() {
                if let name = names.first(where: { ($0.value.index + 1) == index })?.key {
                    result[name, default: []].append(substring)
                }
            }
        }
        
        return result
    }
}

extension RegularExpression {
    func nonCaptureGroup() -> Self {
        guard !pattern.isEmpty, !(compoundContainerType == .nonCapturing) else {
            return self
        }
        
        return modifyPattern { pattern in
            "(?:" + pattern + ")"
        }
    }
    
    func captureGroup(named name: String?) -> Self {
        return decomposeNonCaptureGroupIfNecessary().modifyPattern {
            "(".appending(name.map({ "?<\($0)>" }) ?? "").appending($0).appending(")")
        }
    }
    
    func groupIfNecessary() -> Self {
        guard compoundContainerType == nil else {
            return self
        }
        
        return nonCaptureGroup()
    }
}

// MARK: - Auxiliary

fileprivate extension RegularExpression {
    enum CompoundContainerType {
        case nonCapturing
        case capturing
    }
    
    var compoundContainerType: CompoundContainerType? {
        let first: Character? = pattern.first
        let last: Character? = pattern.last

        if pattern.count >= 3, (pattern[try: pattern.startIndex..<pattern.index(pattern.startIndex, offsetBy: 3)] == "(?:") && (pattern.last == Character(")")) {
            return .nonCapturing
        } else if (first == Character("(")) && (last == Character(")")) {
            return .capturing
        } else {
            return nil
        }
    }
    
    func decomposeNonCaptureGroupIfNecessary() -> Self {
        guard compoundContainerType == .nonCapturing else {
            return self
        }
        
        var pattern = self.pattern
        
        pattern.remove(at: pattern.lastIndex!)
        pattern.removeFirst(3)
        
        return .init(pattern: pattern)
    }
}

fileprivate extension NSRegularExpression {
    typealias GroupNamesSearchResult = (NSTextCheckingResult, NSTextCheckingResult, index: Int)
    
    func textCheckingResultsOfNamedCaptureGroups() -> [String: GroupNamesSearchResult] {
        TODO.whole(.refactor) {
            var result = [String: GroupNamesSearchResult]()
            
            let greg = try! NSRegularExpression(pattern: "^\\(\\?<([\\w\\a_-]*)>$", options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let reg = try! NSRegularExpression(pattern: "\\(.*?>", options: NSRegularExpression.Options.dotMatchesLineSeparators)
            
            let m = reg.matches(
                in: pattern,
                options: NSRegularExpression.MatchingOptions.withTransparentBounds,
                range: NSRange(location: 0, length: pattern.utf16.count)
            )
            
            var counter: Int = 0
            
            for (n, g) in m.enumerated() {
                let r = Range(g.range(at: 0), in: pattern)
                let gstring = String(pattern[r!])
                
                let gmatch = greg.matches(
                    in: gstring,
                    options: NSRegularExpression.MatchingOptions.anchored,
                    range: NSRange(location: 0, length: gstring.utf16.count)
                )
                
                if gmatch.count > 0 {
                    let r2 = Range(gmatch[0].range(at: 1), in: gstring)!
                    result[String(gstring[r2])] = (g, gmatch[0], n + counter)
                } else {
                    counter -= 1
                }
            }
            
            return result
        }
    }
}
