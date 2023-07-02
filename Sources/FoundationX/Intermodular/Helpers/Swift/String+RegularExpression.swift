//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension String {
    public func ranges(
        matchedBy expression: RegularExpression
    ) -> [Range<String.Index>] {
        expression.matchRanges(in: self)
    }
}

extension String {
    public func matches(_ expression: RegularExpression) -> Bool {
        !ranges(matchedBy: expression).isEmpty
    }
    
    public func matches(theWholeOf expression: RegularExpression) -> Bool {
        ranges(matchedBy: expression).find({ $0 == self.bounds }) != nil
    }
}

extension String {
    public func matchAndCaptureRanges(with expression: RegularExpression) -> [(Range<String.Index>, [Range<String.Index>?])] {
        expression.matchAndCaptureRanges(in: self)
    }
    
    public func captureRanges(with expression: RegularExpression) -> [[Range<String.Index>?]] {
        expression.captureRanges(in: self)
    }
    
    public func captureFirstRanges(with expression: RegularExpression) -> [Range<String.Index>?] {
        expression.captureFirstRanges(in: self)
    }
}

extension String {
    public func matchAndCaptureSubstrings(
        with expression: RegularExpression
    ) -> [(Substring, [Substring?])] {
        matchAndCaptureRanges(with: expression).map {
            (self[$0.0], $0.1.map({ $0.map({ self[$0] }) }))
        }
    }
    
    public func substrings(matchedBy expression: RegularExpression) -> [Substring] {
        ranges(matchedBy: expression).map({ self[$0] })
    }
    
    public func strings(matchedBy expression: RegularExpression) -> [String] {
        substrings(matchedBy: expression).map(String.init)
    }
    
    public func strings(capturedBy expression: RegularExpression) -> [[Substring?]] {
        captureRanges(with: expression).map({ $0.map({ $0.map({ self[$0] }) }) })
    }
    
    public func substrings(firstCapturedBy expression: RegularExpression) -> [Substring?] {
        captureFirstRanges(with: expression).map({ $0.map({ self[$0] }) })
    }
    
    public func strings(firstCapturedBy expression: RegularExpression) -> [String?] {
        substrings(firstCapturedBy: expression).map({ $0.map(String.init) })
    }
}

extension String {
    public mutating func replace(_ expression: RegularExpression, with other: String) {
        self = replacing(expression, with: other)
    }
    
    public func replacing(
        _ expression: RegularExpression,
        with other: String
    ) -> String {
        replacing(expression, withTemplate: NSRegularExpression.escapedTemplate(for: other))
    }
    
    public mutating func replace(
        _ expression: RegularExpression,
        withTemplate template: String
    ) {
        self = replacing(expression, withTemplate: template)
    }
    
    public func replacing(
        _ expression: RegularExpression,
        withTemplate template: String
    ) -> String {
        (expression as NSRegularExpression).stringByReplacingMatches(in: self, options: [], range: .init(0..<count), withTemplate: template)
    }
}

extension String {
    public mutating func replaceSubstrings(
        _ substrings: [Substring],
        with replacements: [String]
    ) {
        replaceSubranges(substrings.lazy.map({ $0.bounds }), with: replacements)
    }
    
    public func replacingSubstrings(
        _ substrings: [Substring],
        with replacements: [String]
    ) -> Self {
        build(self) {
            $0.replaceSubstrings(substrings, with: replacements)
        }
    }
    
    public mutating func mutateStrings(
        matchedBy expression: RegularExpression,
        _ mutate: ((_ string: inout String, _ relativeMatches: [Substring?]) -> Void)
    ) {
        let matches = matchAndCaptureSubstrings(with: expression)
        var replacements: [String] = []
        
        for (matchedSubstring, capturedSubstrings) in matches {
            var matchedString = String(matchedSubstring)
            
            let relativeCapturedStrings = capturedSubstrings
                .map({ substring -> Range<String.Index>? in
                    guard let substring = substring else {
                        return nil
                    }
                    
                    guard !substring.isEmpty else {
                        fatalError()
                    }
                    
                    let relativeLowerBoundDistance = matchedSubstring.distance(from: matchedSubstring.startIndex, to: substring.startIndex)
                    let relativeUpperBoundDistance = matchedSubstring.distance(from: matchedSubstring.startIndex, to: substring.endIndex)
                    
                    let lowerBound = matchedString.index(matchedString.startIndex, offsetBy: relativeLowerBoundDistance)
                    let upperBound = matchedString.index(matchedString.startIndex, offsetBy: relativeUpperBoundDistance)
                    
                    return lowerBound..<upperBound
                })
                .map {
                    $0.map { range -> Substring in
                        return matchedString[range]
                    }
                }
            
            mutate(&matchedString, relativeCapturedStrings)
            
            replacements.append(matchedString)
        }
        
        replaceSubstrings(matches.lazy.map({ $0.0 }), with: replacements)
    }
    
    public mutating func replaceLines(
        matching expression: RegularExpression,
        with replacement: String
    ) {
        replace(substrings: self.lines().filter({ $0.matches(expression) }), with: replacement)
    }
    
    public mutating func removeLines(
        matching expression: RegularExpression
    ) {
        replaceLines(matching: expression, with: "")
    }
}
