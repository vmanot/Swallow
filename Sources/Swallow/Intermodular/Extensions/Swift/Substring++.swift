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
    public func components(separatedBy separator: Character) -> [Substring] {
        return split(whereSeparator: { $0 == separator })
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
        guard let lastIndex else {
            return self
        }
        
        var index = lastIndex
        
        while containsIndex(index), self[index] == character {
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
        guard let lastIndex else {
            return self
        }
        
        var index = lastIndex
        
        while containsIndex(index), CharacterSet(charactersIn: String(self[index])).isSubset(of: characterSet) {
            index = self.index(index, offsetBy: -1)
        }
        
        guard startIndex != index else {
            return self[startIndex..<self.index(startIndex, offsetBy: 1)]
        }
        
        return self[startIndex...index]
    }
    
    @_disfavoredOverload
    public func trimming(_ character: Character) -> Substring {
        trimming(leading: character).trimming(trailing: character)
    }
    
    @_disfavoredOverload
    public func trimmingCharacters(in characterSet: CharacterSet) -> Substring {
        trimmingLeadingCharacters(in: characterSet).trimmingTrailingCharacters(in: characterSet)
    }
    
    public func trimmingNewlines() -> Substring {
        trimming("\n")
    }
}
