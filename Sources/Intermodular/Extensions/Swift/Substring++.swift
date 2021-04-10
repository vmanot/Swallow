//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Substring {
    public mutating func replace(occurencesOf target: String, with string: String) {
        TODO.whole(.optimize, note: "use regex to grab all ranges and replace in place")
        
        self = Substring(replacingOccurrences(of: target, with: string, options: .literal, range: nil))
    }
    
    public mutating func replace(firstOccurenceOf target: String, with string: String) {
        TODO.whole(.remove, note: "replace with RangeReplaceableCollection function")
        
        guard let range = range(of: target, options: .literal) else {
            return
        }
        
        replaceSubrange(range, with: string)
    }
}

extension Substring {
    public init(consuming left: Substring, and right: Substring) {
        assert(left.parent == right.parent)
        assert(left.bounds <~= right.bounds)
        
        self = left.parent[left.bounds.lowerBound..<right.bounds.upperBound]
    }
}

extension Substring {
    public func components(separatedBy separator: Character) -> [Substring] {
        return split(whereSeparator: { $0 == separator })
    }
    
    public mutating func extendBackwardsTillBeforeComponent(predicate: ((Substring) -> Bool), separator: Character) {
        let body = splitParentAboutSelf().0
        
        if let last = body.components(separatedBy: separator).reversed().element(before: predicate) {
            extend(upToAndInclusiveOf: last)
        }
    }
    
    public mutating func extend(upToAndInclusiveOf substring: Substring) {
        assert(parent.contains(substring: substring))
        
        if substring.bounds <~= bounds {
            self = parent[substring.bounds.lowerBound..<bounds.upperBound]
        } else {
            self = parent[bounds.lowerBound..<substring.bounds.upperBound]
        }
    }
}

extension Substring {
    public func substringOneCharacterMoreFromParentStart() -> Substring {
        return parent[parent.index(before: bounds.lowerBound)..<bounds.upperBound]
    }
    
    public func substringOneCharacterMoreFromParentEnd() -> Substring {
        return parent[parent.index(before: bounds.lowerBound)..<bounds.upperBound]
    }
    
    public func splitParentAboutSelf() -> (Substring, Substring) {
        return (parent[..<bounds.lowerBound], parent[bounds.upperBound...])
    }
    
    public func parentSubstringAboutSelf<String: StringProtocol>(from start: String, to end: String) -> Substring? {
        let (first, last) = splitParentAboutSelf()
        
        guard let firstMatch = first.range(of: start, options: .backwards),
              let secondMatch = last.range(of: end) else {
            return nil
        }
        
        return parent[firstMatch.lowerBound..<secondMatch.upperBound]
    }
}

extension Substring {
    public var parent: String {
        // FIXME: Replace with semantically versioned code block.
        #if swift(>=4.1)
        return (-*>self as Slice<String>).base
        #endif
    }
}

extension Substring {
    public func contains(substring: Substring) -> Bool {
        guard substring.parent == substring.parent else {
            return false
        }
        
        return bounds.contains(substring.bounds)
    }
    
    public func contains(substring: Substring?) -> Bool {
        return substring.map({ contains(substring: $0) }) ?? false
    }
    
    public init(across substrings: Substring...) {
        let parent = substrings.first!.parent
        
        assert {
            substrings.map({ $0.parent }).allElementsAreEqual()
        }
        
        if let first = substrings.first, let last = substrings.last {
            self = parent[first.startIndex..<last.endIndex]
        } else {
            self = parent[parent.startIndex...]
        }
    }
}

extension Substring {
    public func firstLine() -> Substring {
        return split(separator: "\n").first!
    }
    
    public func lastLine() -> Substring {
        return split(separator: "\n").last!
    }
}

extension Substring {
    public func trimming(leading character: Character) -> Substring {
        guard !isEmpty else {
            return self
        }
        
        var index = startIndex
        
        while index != endIndex, self[index] == character {
            index = self.index(index, offsetBy: 1)
        }
        
        return self[index..<endIndex]
    }
    
    public func trimming(trailing character: Character) -> Substring {
        guard !isEmpty else {
            return self
        }
        
        var index = lastIndex
        
        while contains(index), self[index] == character {
            index = self.index(index, offsetBy: -1)
        }
        
        guard startIndex != index else {
            return self[startIndex..<self.index(startIndex, offsetBy: 1)]
        }
        
        return self[startIndex...index]
    }
    
    public func trimmingLeadingCharacters(
        in characterSet: CharacterSet,
        maximum: Int? = nil
    ) -> Substring {
        if maximum == 0 {
            return self
        }
        
        guard !isEmpty else {
            return self
        }
        
        var index = startIndex
        var count = 0
        
        while CharacterSet(charactersIn: String(self[index])).isSubset(of: characterSet) {
            index = self.index(index, offsetBy: 1)
            
            count += 1
            
            if count == maximum {
                break
            }
            
            guard index < endIndex, index != endIndex else {
                break
            }
        }

        return self[index..<endIndex]
    }
        
    public func trimmingTrailingCharacters(
        in characterSet: CharacterSet
    ) -> Substring {
        guard !isEmpty else {
            return self
        }
        
        var index = lastIndex
        
        while contains(index), CharacterSet(charactersIn: String(self[index])).isSubset(of: characterSet) {
            index = self.index(index, offsetBy: -1)
        }
        
        guard startIndex != index else {
            return self[startIndex..<self.index(startIndex, offsetBy: 1)]
        }
        
        return self[startIndex...index]
    }
    
    public func trimming(_ character: Character) -> Substring {
        trimming(leading: character).trimming(trailing: character)
    }
    
    public func trimmingCharacters(in characterSet: CharacterSet) -> Substring {
        trimmingLeadingCharacters(in: characterSet).trimmingTrailingCharacters(in: characterSet)
    }
    
    public func trimmingNewlines() -> Substring {
        trimming("\n")
    }
}
