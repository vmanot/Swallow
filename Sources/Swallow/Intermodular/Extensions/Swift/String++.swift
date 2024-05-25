//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension String {
    public init(_staticString string: StaticString) {
        self = string.withUTF8Buffer({ String(decoding: $0, as: UTF8.self) })
    }
    
    public init(
        describing operation: () throws -> some CustomStringConvertible,
        recovery: () -> String
    ) {
        do {
            let result = try operation()
            
            if let result = result as? String {
                self = result
            } else {
                self = result.description
            }
        } catch {
            self = recovery()
        }
    }

    /// Creates a new string from a single UTF-16 code unit.
    public init(utf16CodeUnit: UTF16.CodeUnit) {
        self.init(utf16CodeUnits: [utf16CodeUnit], count: 1)
    }
    
    public subscript(
        _utf16Range range: Range<Int>
    ) -> Substring {
        self[_fromUTF16Range(range)!]
    }
    
    public subscript(
        _utf16Range range: PartialRangeFrom<Int>
    ) -> Substring {
        self[_fromUTF16Range(range)!]
    }
    
    public var _utf16Bounds: Range<Int> {
        _toUTF16Range(bounds)
    }
    
    public func _fromUTF16Range(
        _ range: NSRange
    ) -> Range<String.Index>? {
        Range(range, in: self)
    }
    
    public func _fromUTF16Range(
        _ range: Range<Int>
    ) -> Range<String.Index>? {
        Range(NSRange(location: range.lowerBound, length: range.upperBound - range.lowerBound), in: self)
    }
    
    public func _fromUTF16Range(
        _ range: PartialRangeFrom<Int>
    ) -> Range<String.Index>? {
        _fromUTF16Range(range.lowerBound..<_toUTF16Range(bounds).upperBound)
    }
    
    public func _toUTF16Range(
        _ range: Range<String.Index>
    ) -> Range<Int> {
        let range = NSRange(range, in: self)
        
        return range.location..<(range.location + range.length)
    }
    
    public func _toUTF16Range(
        _ range: PartialRangeFrom<String.Index>
    ) -> Range<Int> {
        let range = NSRange(range, in: self)
        
        return range.location..<(range.location + range.length)
    }
}

extension String {
    public func delimited(by character: Character) -> String {
        "\(character)\(self)\(character)"
    }
}

extension String {
    public static func concatenate(
        separator: String,
        @_SpecializedArrayBuilder<String> _ strings: () throws -> [String]
    ) rethrows -> Self {
        try strings().joined(separator: separator)
    }
}

extension String {
    public var firstCharacterCapitalized: String {
        prefix(1).capitalized + dropFirst()
    }
    
    public func hasPrefix(_ prefix: String, caseInsensitive: Bool) -> Bool {
        if caseInsensitive {
            return range(of: prefix, options: [.anchored, .caseInsensitive]) != nil
        } else {
            return hasPrefix(prefix)
        }
    }

    public func numberOfOccurences(of character: Character) -> Int {
        lazy.filter({ $0 == character }).count
    }
}

extension String {
    public func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + String(dropFirst())
    }
    
    public mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension String {
    public mutating func replaceSubstring(
        _ substring: Substring,
        with replacement: String
    ) {
        replaceSubrange(substring.bounds, with: replacement)
    }
    
    public mutating func replace(
        substrings: [Substring],
        with string: String
    ) {
        replaceSubranges(
            substrings.lazy.map({ $0.bounds }),
            with: substrings.lazy.map({ _ in string })
        )
    }
    
    public mutating func replace<String: StringProtocol>(
        occurencesOf target: String,
        with string: String
    ) {
        self = replacingOccurrences(of: target, with: string, options: .literal, range: nil)
    }
    
    public mutating func replace<String: StringProtocol>(
        firstOccurenceOf target: String,
        with string: String
    ) {
        TODO.whole(.remove, note: "replace with RangeReplaceableCollection function")
        
        guard let range = range(of: target, options: .literal) else {
            return
        }
        
        replaceSubrange(range, with: string)
    }
    
    public mutating func remove(substrings: [Substring]) {
        replace(substrings: substrings, with: "")
    }
}

extension String {
    @_disfavoredOverload
    public func contains(only characterSet: CharacterSet) -> Bool {
        CharacterSet(charactersIn: self).isSubset(of: characterSet)
    }
    
    public func removingCharacters(
        in characterSet: CharacterSet
    ) -> String {
        String(String.UnicodeScalarView(unicodeScalars.lazy.filter {
            !characterSet.contains($0)
        }))
    }
    
    public func removingCharacters(in string: String) -> String {
        removingCharacters(in: CharacterSet(charactersIn: string))
    }
    
    public func removingLeadingCharacters(
        in characterSet: CharacterSet
    ) -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
            return self
        }
        
        return String(self[index...])
    }
    
    public func removingTrailingCharacters(
        in characterSet: CharacterSet
    ) -> String {
        guard let range = self.rangeOfCharacter(from: characterSet.inverted, options: .backwards) else {
            return ""
        }
        
        return String(self[..<range.upperBound])
    }
    
    public func dropFirstComponent(
        separatedBy separator: String
    ) -> String {
        let components = self.components(separatedBy: separator)
        
        guard components.count > 1 else {
            return self
        }
        
        return components.dropFirst().joined(separator: separator)
    }
    
    public func dropFirstComponent(
        separatedBy character: Character
    ) -> String {
        dropFirstComponent(separatedBy: String(character))
    }

    public func dropLastComponent(
        separatedBy separator: String
    ) -> String {
        let components = self.components(separatedBy: separator)
        
        guard components.count > 1 else {
            return self
        }
        
        return components.dropLast().joined(separator: separator)
    }

    @_disfavoredOverload
    public func trim(prefix: String, suffix: String) -> Substring {
        if hasPrefix(prefix) && hasSuffix(suffix) {
            return dropFirst(prefix.count).dropLast(suffix.count)
        } else {
            return self[bounds]
        }
    }
    
    public func trim(prefix: String, suffix: String) -> String {
        String(trim(prefix: prefix, suffix: suffix) as Substring)
    }
}

extension String {
    public func tabIndent(_ count: Int) -> String {
        return String(repeatElement("\t", count: count)) + self
    }
    
    public mutating func appendLine(_ string: String) {
        self += (string + "\n")
    }
    
    public mutating func appendTabIndentedLine( _ count: Int, _ string: String) {
        appendLine(String(repeatElement("\t", count: count)) + string)
    }
    
    public mutating func modifyLines(
        _ modify: (inout String) -> Void
    ) {
        // Define a structure to hold line content and its original newline character
        struct Line {
            var content: String
            let newline: String
        }
        
        // Array to hold lines along with their respective newline characters
        var linesWithNewlines: [Line] = []
        var searchStartIndex = self.startIndex
        
        // Regular expression to match newline characters (\n, \r\n, or \r)
        let newlineRegex = try! NSRegularExpression(pattern: "\r\n|[\n\r]")
        
        // Iterate over the string to find and split by newline characters
        while let match = newlineRegex.firstMatch(in: self, range: NSRange(searchStartIndex..<self.endIndex, in: self)) {
            let range = Range(match.range, in: self)!
            let lineContent = String(self[searchStartIndex..<range.lowerBound])
            let newlineStr = String(self[range.lowerBound..<range.upperBound])
            linesWithNewlines.append(Line(content: lineContent, newline: newlineStr))
            searchStartIndex = range.upperBound
        }
        
        // Add the last line if there's any content left without a trailing newline
        if searchStartIndex < self.endIndex {
            linesWithNewlines.append(Line(content: String(self[searchStartIndex..<self.endIndex]), newline: ""))
        }
        
        // Modify each line using the provided closure and collect the results
        for i in linesWithNewlines.indices {
            var lineToModify = linesWithNewlines[i].content
            
            modify(&lineToModify)
            
            linesWithNewlines[i].content = lineToModify
        }
        
        // Reconstruct the string, preserving original newline characters
        self = linesWithNewlines
            .map {
                $0.content + $0.newline
            }
            .joined()
    }
    
    public func modifyingLines(_ modify: (inout String) -> Void) -> String {
        withMutableScope(self) {
            $0.modifyLines(modify)
        }
    }
    
    public func mapLines(_ transform: (String) -> String) -> String {
        withMutableScope(self) {
            $0.modifyLines({ $0 = transform($0) })
        }
    }
}

extension String {
    public func trimmingWhitespace() -> String {
        trimmingCharacters(in: .whitespaces)
    }
    
    public func trimmingWhitespaceAndNewlines() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// This method removes all newlines and whitespaces from the string.
    ///
    /// This is **not** the same as trimming.
    public func _removingAllNewlinesAndWhitespaces() -> String {
        let string = (self as NSString)
        
        return string.replacingOccurrences(
            of: "\\s+",
            with: "",
            options: NSString.CompareOptions.regularExpression,
            range: NSRange(location: 0, length: string.length)
        ) as String
    }
}

extension String {
    public func _componentsWithRanges(
        separatedBy separator: String)
    -> [(String, Range<String.Index>)] {
        var ranges: [(String, Range<String.Index>)] = []
        var currentRangeStart = startIndex
        
        while let separatorRange = range(of: separator, options: [], range: currentRangeStart..<endIndex) {
            let componentRange = currentRangeStart..<separatorRange.lowerBound
            let component = String(self[componentRange])
            
            ranges.append((component, componentRange))
            
            currentRangeStart = separatorRange.upperBound
        }
        
        let remainingComponentRange = currentRangeStart..<endIndex
        let remainingComponent = String(self[remainingComponentRange])
        
        ranges.append((remainingComponent, remainingComponentRange))
        
        return ranges
    }
    
    public func splitInHalf(separator: String) -> (String, String) {
        let range = range(of: separator, range: nil, locale: nil)
        
        if let range = range {
            let lhs = String(self[..<range.lowerBound])
            let rhs = String(self[range.upperBound...])
            return (lhs, rhs)
        }
        
        return (self, "")
    }
    
    public func substrings(
        separatedBy characterSet: CharacterSet
    ) -> [Substring] {
        var result: [Substring] = []
        var start = self.startIndex
        
        while start < self.endIndex {
            if let range = self.rangeOfCharacter(from: characterSet, options: [], range: start..<self.endIndex) {
                if range.lowerBound != start {
                    result.append(self[start..<range.lowerBound])
                }
                
                if range.upperBound < self.endIndex {
                    start = range.upperBound
                } else {
                    break
                }
            } else {
                result.append(self[start..<self.endIndex])
                
                break
            }
        }
        
        return result
    }
}
