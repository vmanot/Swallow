//
// Copyright (c) Vatsal Manot
//

import Swift

extension String {
    public init(_staticString string: StaticString) {
        self = string.withUTF8Buffer({ String(decoding: $0, as: UTF8.self) })
    }
    
    /// Creates a new string from a single UTF-16 code unit.
    public init(utf16CodeUnit: UTF16.CodeUnit) {
        self.init(utf16CodeUnits: [utf16CodeUnit], count: 1)
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
}

extension String {
    public func trimmingWhitespace() -> String {
        trimmingCharacters(in: .whitespaces)
    }
}

extension String {
    public func splitInHalf(separator: String) -> (String, String) {
        let range = range(of: separator, range: nil, locale: nil)
        
        if let range = range {
            let lhs = String(self[..<range.lowerBound])
            let rhs = String(self[range.upperBound...])
            return (lhs, rhs)
        }
        
        return (self, "")
    }
}
