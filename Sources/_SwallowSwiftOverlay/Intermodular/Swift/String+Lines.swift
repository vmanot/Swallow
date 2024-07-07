//
// Copyright (c) Vatsal Manot
//

import Swift

extension String {
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
    
    public func _detectedLineEndingCharacter() -> Character {
        guard let last, last.isNewline else {
            return .newline
        }
        
        return last
    }
    
    public func _breakLines(
        proposedLineEnding: String? = nil,
        appendLineBreakToLastLine: Bool = false
    ) -> [String] {
        let lineEndingInText: Character = _detectedLineEndingCharacter()
        let lineEnding: String = proposedLineEnding ?? String(lineEndingInText)
        let lines: [Substring] = split(separator: lineEndingInText, omittingEmptySubsequences: false)
        
        var result = [String]()
        
        for (index, line) in lines.enumerated() {
            if !appendLineBreakToLastLine, index == lines.endIndex - 1 {
                result.append(String(line))
            } else {
                result.append(String(line) + lineEnding)
            }
        }
        
        return result
    }
    
    public func _linesWithWhitespacesAndNewlinesTrimmed() -> [String] {
        split(separator: .newline)
            .map { (substring: Substring) in
                substring.trimmingCharacters(in: .newlines)
            }
    }
    
    public func _splitByNewLine(
        omittingEmptySubsequences: Bool = true,
        estimateLineEnding: Bool = true
    ) -> [Substring] {
        if estimateLineEnding {
            let lineEndingInText: Character = _detectedLineEndingCharacter()
            
            return split(
                separator: lineEndingInText,
                omittingEmptySubsequences: omittingEmptySubsequences
            )
        }
        
        return split(
            omittingEmptySubsequences: omittingEmptySubsequences,
            whereSeparator: \.isNewline
        )
    }
}
