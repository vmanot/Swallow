//
// Copyright (c) Vatsal Manot
//

import Swift

extension Character {
    init(_ i: Int) {
        self.self = Character(UnicodeScalar(i)!)
    }
}

extension Character {
    var unicode: Unicode.Scalar {
        return self.unicodeScalars.first!
    }

    var properties: Unicode.Scalar.Properties {
        return self.unicode.properties
    }

    var uppercaseMapping: String {
        return self.properties.uppercaseMapping
    }

    var lowercaseMapping: String {
        return self.properties.lowercaseMapping
    }

    var titlecaseMapping: String {
        return self.properties.titlecaseMapping
    }

    func toUpper() -> Character {
        return Character(self.uppercaseMapping)
    }

    func toLower() -> Character {
        return Character(self.lowercaseMapping)
    }

    func toTitle() -> Character {
        return Character(self.titlecaseMapping)
    }

    var isTitlecase: Bool {
        return properties.generalCategory == .titlecaseLetter
    }

    func isdecimal() -> Bool {
        return self.properties.generalCategory == .decimalNumber
    }

    func isdigit() -> Bool {
        if let numericType = self.properties.numericType {
            return numericType == .decimal || numericType == .digit
        }
        return false
    }
}

extension String {
    func at(_ i: Int) -> Character? {
        if self.count > i {
            return self[self.index(self.startIndex, offsetBy: i)]
        }
        return nil
    }
   
    func capitalize() -> String {
        if let f = first {
            return f.titlecaseMapping + dropFirst().lowercased()
        }
        return self
    }
   
    func casefold() -> String {
        return map { casefoldTable[$0.unicode.value, default: String($0)] }.joined()
    }
    
    func center(_ width: Int, fillchar: Character = " ") -> String {
        if self.count >= width {
            return self
        }
        let left = width - self.count
        let right = left / 2 + left % 2
        return fillchar * (left - right) + self + fillchar * right
    }
   
    func count(_ sub: String, start: Int? = nil, end: Int? = nil) -> Int {
        let (s, e) = adjustIndex(start, end)
        if (e - s < sub.count) { return 0 }
        if sub.isEmpty {
            return Swift.max(e - s, 0) + 1
        }
        var n = find(sub, start: s, end: e)
        var c = 0
        while n != -1 {
            c += 1
            n = find(sub, start: n + sub.count, end: e)
        }
        return c
    }
    
    func endswith(_ suffix: String, start: Int? = nil, end: Int? = nil) -> Bool {
        let (s, e) = adjustIndex(start, end)
        if (e - s < suffix.count) { return false }
        return suffix.isEmpty || slice(start: s, end: e).hasSuffix(suffix)
    }
   
    func endswith(_ suffixes: [String], start: Int? = nil, end: Int? = nil) -> Bool {
        return suffixes.contains(where: { endswith($0, start: start, end: end) })
    }
   
    func expandtabs(_ tabsize: Int = 8) -> String {
        var buffer = ""
        buffer.reserveCapacity(count + count("\t") * tabsize)
        var linePos = 0
        for ch in self {
            if (ch == "\t") {
                if (tabsize > 0) {
                    let incr = tabsize - (linePos % tabsize)
                    linePos += incr
                    buffer.append(" " * incr)
                }
            } else {
                linePos += 1
                buffer.append(ch)
                if (ch == "\n" || ch == "\r" || ch == "\r\n") {
                    linePos = 0
                }
            }
        }
        return buffer
    }
    
    func find(_ sub: String, start: Int? = nil, end: Int? = nil) -> Int {
        let (s, e) = adjustIndex(start, end)
        if (e - s < sub.count) { return -1 }
        if sub.isEmpty {
            return s
        }
        let start = index(startIndex, offsetBy: s)
        let end = index(startIndex, offsetBy: e)
        if let range = range(of: sub, options: .init(), range: start..<end) {
            return distance(from: startIndex, to: range.lowerBound)
        }
        return -1
    }
  
    func index(_ sub: String, start: Int? = nil, end: Int? = nil) throws -> Int {
        let i = self.find(sub, start: start, end: end)
        if i == -1 {
            throw PyException.valueError("substring not found")
        }
        return i
    }
   
    private func isX(_ conditional: (Character) -> Bool, empty: Bool) -> Bool {
        if self.isEmpty {
            return empty
        }
        return self.allSatisfy({ conditional($0) })
    }
    
    func isalnum() -> Bool {
        let alphaTypes: [Unicode.GeneralCategory] = [.modifierLetter, .titlecaseLetter, .uppercaseLetter, .lowercaseLetter, .otherLetter, .decimalNumber]
        return self.isX({ (chr) -> Bool in
            return alphaTypes.contains(chr.properties.generalCategory) || chr.properties.numericType != nil
        }, empty: false)
    }
    
    func isalpha() -> Bool {
        let alphaTypes: [Unicode.GeneralCategory] = [.modifierLetter, .titlecaseLetter, .uppercaseLetter, .lowercaseLetter, .otherLetter]
        return self.isX({ (chr) -> Bool in
            return alphaTypes.contains(chr.properties.generalCategory)
        }, empty: false)
    }
    
    func isascii() -> Bool {
        return self.isX({ (chr) -> Bool in
            return 0 <= chr.unicode.value && chr.unicode.value <= 127
        }, empty: true)
    }
    
    func isdecimal() -> Bool {
        return self.isX({ (chr) -> Bool in
            return chr.properties.generalCategory == .decimalNumber
        }, empty: false)
    }
    
    func isdigit() -> Bool {
        return self.isX({ (chr) -> Bool in
            if let numericType = chr.properties.numericType {
                return numericType == .decimal || numericType == .digit
            }
            return false
        }, empty: false)
    }
    func islower() -> Bool {
        if self.isEmpty {
            return false
        }
        var hasCase = false
        for chr in self {
            if chr.isCased {
                if !chr.isLowercase {
                    return false
                }
                hasCase = true
            }
        }
        return hasCase
    }
    
    func isnumeric() -> Bool {
        return self.isX({ (chr) -> Bool in
            return chr.properties.numericType != nil
        }, empty: false)
    }
    
    func isprintable() -> Bool {
        let otherTypes: [Unicode.GeneralCategory] = [.otherLetter, .otherNumber, .otherSymbol, .otherPunctuation]
        let separatorTypes: [Unicode.GeneralCategory] = [.lineSeparator, .spaceSeparator, .paragraphSeparator]
        let maybeDisPrintable = otherTypes + separatorTypes
        return self.isX({ (chr) -> Bool in
            if maybeDisPrintable.contains(chr.properties.generalCategory) {
                return chr == " "
            }
            return true
        }, empty: true)
    }
    
    func isspace() -> Bool {
        return self.isX({ (chr) -> Bool in
            // TODO:unicode propaty
            return chr.isWhitespace
        }, empty: false)
    }
   
    func istitle() -> Bool {
        if isEmpty {
            return false
        }
        var cased = false
        var previousIsCased = false
        for ch in self {
            if (ch.isUppercase || ch.isTitlecase) {
                if (previousIsCased) {
                    return false
                }
                previousIsCased = true
                cased = true
            } else if (ch.isLowercase) {
                if (!previousIsCased) {
                    return false
                }
                previousIsCased = true
                cased = true
            }
            else {
                previousIsCased = false
            }
        }
        return cased
    }
  
    func isupper() -> Bool {
        if self.isEmpty {
            return false
        }
        var hasCase = false
        for chr in self {
            if chr.isCased {
                if !chr.isUppercase {
                    return false
                }
                hasCase = true
            }
        }
        return hasCase
    }
 
    func join(_ iterable: [String]) -> String {
        return iterable.joined(separator: self)
    }

    func join<T: Sequence>(_ iterable: T) -> String where T.Element == Character {
        return String(iterable.reduce(into: "") { (result, char) in
            result.append(char)
            result.append(self)
        }.dropLast(count))
    }
    func join<T: Sequence, U: StringProtocol>(_ iterable: T) -> String where T.Element == U {
        return String(iterable.reduce(into: "") { (result, char) in
            result.append(contentsOf: char)
            result.append(self)
        }.dropLast(count))
    }
    func rjust(_ width: Int, fillchar: Character = " ") -> String {
        if self.count >= width {
            return self
        }
        let w = width - self.count
        return fillchar * w + self
    }
    func lower() -> String {
        return self.lowercased()
    }
    func lstrip(_ chars: String? = nil) -> String {
        if let chars = chars {
            return String(drop(while: { chars.contains($0) }))
        }
        return String(drop(while: { $0.isWhitespace }))
    }
    static func maketrans(_ x: [UInt32: String?]) -> [Character: String] {
        var _x: [Character: String?] = [:]
        for (key, value) in x {
            _x[Character(UnicodeScalar(key)!)] = value
        }
        return maketrans(_x)
    }
   
    static func maketrans(_ x: [Character: String?]) -> [Character: String] {
        var cvTable: [Character: String] = [:]
        for (key, value) in x {
            cvTable[key] = value ?? ""
        }
        return cvTable
    }
    
    static func maketrans(_ x: String, y: String, z: String = "") -> [Character: String] {
        var cvTable: [Character: String] = [:]
        let loop: Int = Swift.max(x.count, y.count)
        for i in 0..<loop {
            cvTable[x[i]] = String(y[i])
        }
        for chr in z {
            cvTable[chr] = ""
        }
        return cvTable
    }
   
    func partition(_ sep: String) -> (String, String, String) {
        let tmp = self.split(sep, maxsplit: 1)
        if tmp.count == 1 {
            return (self, "", "")
        }
        return (tmp[0], sep, tmp[1])
    }
    
    /// If the string ends with the suffix string and that suffix is not empty, return string[null, -suffix.count].
    /// Otherwise, return a copy of the original string.
    func removesuffix(_ suffix: String) -> String {
        if endswith(suffix) {
            return String(dropLast(suffix.count))
        }
        return self
    }
    
    /// If the string starts with the prefix string, return string[prefix.count, null].
    /// Otherwise, return a copy of the original string.
    func removeprefix(_ prefix: String) -> String {
        if startswith(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }
    
    func replace(_ old: String, new: String, count: Int = Int.max) -> String {
        if old.isEmpty {
            if isEmpty {
                if count == .zero {
                    return ""
                }
                return new
            }
            return repleceEmpty(to: new, count: count)
        }
        return new.join(split(old, maxsplit: count))
    }
    func repleceEmpty(to new: String, count: Int) -> String {
        if count == .zero {
            return self
        }
        var count = 0 < count ? count : .max
        var buffer = new
        for c in self {
            buffer.append(c)
            count--
            if count > 0 {
                buffer += new
            }
        }
        return buffer
    }
    
    func rfind(_ sub: String, start: Int? = nil, end: Int? = nil) -> Int {
        let (s, e) = adjustIndex(start, end)
        if (e - s < sub.count) { return -1 }
        if sub.isEmpty {
            return count
        }
        let start = index(startIndex, offsetBy: s)
        let end = index(startIndex, offsetBy: e)
        if let range = range(of: sub, options: .backwards, range: start..<end) {
            return distance(from: startIndex, to: range.lowerBound)
        }
        return -1
    }
    
    func rindex(_ sub: String, start: Int? = nil, end: Int? = nil) throws -> Int {
        let i = self.rfind(sub, start: start, end: end)
        if i == -1 {
            throw PyException.valueError("substring not found")
        }
        return i
    }
   
    func ljust(_ width: Int, fillchar: Character = " ") -> String {
        if self.count >= width {
            return self
        }
        let w = width - self.count
        return self + fillchar * w
    }
    
    func rpartition(_ sep: String) -> (String, String, String) {
        let tmp = self._rsplit(sep, maxsplit: 1)
        if tmp.count == 1 {
            return ("", "", self)
        }
        return (tmp[0], sep, tmp[1])
    }
  
    func _rsplit(_ sep: String, maxsplit: Int) -> [String] {
        if self.isEmpty {
            return [self]
        }
        if sep.isEmpty {
            // error
            return self._rsplit(maxsplit: maxsplit)
        }
        var result: [String] = []
        var index = 0, prev_index = Int.max, sep_len = sep.count
        var maxsplit = maxsplit
        if maxsplit < 0 {
            maxsplit = Int.max
        }
        while maxsplit != 0 {
            index = self.rfind(sep, end: prev_index)
            if index == -1 {
                break
            }
            index += sep_len
            result.insert(String(slice(start: index, end: prev_index)), at: 0)
            index -= sep_len
            
            index -= 1
            prev_index = index + 1
            
            maxsplit -= 1
            
            if maxsplit == 0 {
                break
            }
        }
        result.insert(String(slice(start: 0, end: prev_index)), at: 0)
        return result
    }
 
    func _rsplit(maxsplit: Int) -> [String] {
        let maxsplit = maxsplit >= 0 ? maxsplit : .max
        return "".join(reversed()).split(maxSplits: maxsplit, omittingEmptySubsequences: true, whereSeparator: { $0.isWhitespace }).map { "".join(String($0).lstrip().reversed()) }.filter { !$0.isEmpty }.reversed()
    }
  
    func rsplit(_ sep: String? = nil, maxsplit: Int = (-1)) -> [String] {
        if let sep = sep {
            return self._rsplit(sep, maxsplit: maxsplit)
        }
        return self._rsplit(maxsplit: maxsplit)
    }
  
    func rstrip(_ chars: String? = nil) -> String {
        if let chars = chars {
            return "".join(reversed().drop(while: { chars.contains($0) }).reversed())
        }
        return "".join(reversed().drop(while: { $0.isWhitespace }).reversed())
    }
   
    func _split(_ sep: String, maxsplit: Int) -> [String] {
        if self.isEmpty {
            return [self]
        }
        if sep.isEmpty {
            // error
            return self._split(maxsplit: maxsplit)
        }
        var maxsplit = maxsplit
        var result: [String] = []
        if maxsplit < 0 {
            maxsplit = Int.max
        }
        var index = 0, prev_index = 0, sep_len = sep.count
        while maxsplit != 0 {
            index = self.find(sep, start: prev_index)
            if index == -1 {
                break
            }
            result.append(String(slice(start: prev_index, end: index)))
            prev_index = index + sep_len
            
            maxsplit -= 1
        }
        
        result.append(String(slice(start: prev_index, end: nil)))
        
        return result
    }
  
    func _split(maxsplit: Int) -> [String] {
        let maxsplit = maxsplit >= 0 ? maxsplit : .max
        return split(maxSplits: maxsplit, omittingEmptySubsequences: true, whereSeparator: { $0.isWhitespace }).map { String($0).lstrip() }.filter { !$0.isEmpty }
    }
  
    func split(_ sep: String? = nil, maxsplit: Int = (-1)) -> [String] {
        if let sep = sep {
            return self._split(sep, maxsplit: maxsplit)
        }
        return self._split(maxsplit: maxsplit)
    }
   
    func splitlines(_ keepends: Bool = false) -> [String] {
        let lineTokens = "\n\r\r\n\u{0b}\u{0c}\u{1c}\u{1d}\u{1e}\u{85}\u{2028}\u{2029}"
        var len = self.count, i = 0, j = 0, eol = 0
        var result: [String] = []
        while i < len {
            while i < len && !lineTokens.contains(self[i]) {
                i += 1
            }
            eol = i
            if i < len {
                i += 1
                if keepends {
                    eol = i
                }
            }
            result.append(String(slice(start: j, end: eol)))
            j = i
        }
        if j < len {
            result.append(String(slice(start: j, end: eol)))
        }
        return result
    }
   
    func startswith(_ prefix: String, start: Int? = nil, end: Int? = nil) -> Bool {
        let (s, e) = adjustIndex(start, end)
        if (e - s < prefix.count) { return false }
        return prefix.isEmpty || slice(start: s, end: e).hasPrefix(prefix)
    }
   
    func startswith(_ prefixes: [String], start: Int? = nil, end: Int? = nil) -> Bool {
        return prefixes.contains(where: { startswith($0, start: start, end: end) })
    }
    
    func strip(_ chars: String? = nil) -> String {
        return self.lstrip(chars).rstrip(chars)
    }
  
    func swapcase() -> String {
        var swapped = ""
        for chr in self {
            if chr.isASCII {
                if chr.isUppercase {
                    swapped.append(chr.lowercaseMapping)
                } else if chr.isLowercase {
                    swapped.append(chr.uppercaseMapping)
                } else {
                    swapped.append(chr)
                }
            } else {
                swapped.append(chr)
            }
        }
        return swapped
    }
   
    func title() -> String {
        var titled = ""
        var prev_cased = false
        for chr in self {
            if !prev_cased {
                if !chr.isTitlecase {
                    titled.append(chr.titlecaseMapping)
                } else {
                    titled.append(chr)
                }
            } else {
                if chr.isCased {
                    if !chr.isLowercase {
                        titled.append(chr.lowercaseMapping)
                    } else {
                        titled.append(chr)
                    }
                } else {
                    titled.append(chr)
                }
            }
            prev_cased = chr.isCased
        }
        return titled
    }
  
    func translate(_ table: [Character: String]) -> String {
        return map { table[$0, default: String($0)] }.joined()
    }
   
    func upper() -> String {
        return self.uppercased()
    }
 
    func zfill(_ width: Int) -> String {
        if !isEmpty {
            if let h = first, h == "+" || h == "-" {
                return "\(h)\(String(dropFirst()).rjust(width - 1, fillchar: "0"))"
            }
        }
        return rjust(width, fillchar: "0")
    }
}
