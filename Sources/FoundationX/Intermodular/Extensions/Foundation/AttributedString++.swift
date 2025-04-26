//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension AttributedString {
    public mutating func insert(
        _ text: AttributedString,
        atCharacterOffset offset: Int
    ) {
        let index: AttributedString.Index = self.index(startIndex, offsetByCharacters: offset)
        
        insert(text, at: index)
    }
    
    /// **Mutating:** Remove the last *n* characters in‑place (if `n` ≥ count, the string becomes empty).
    /// - Parameter n: Number of characters to trim from the end.
    public mutating func removeLastCharacters(_ n: Int) {
        guard n > 0 else {
            return
        }
        
        let newEnd: AttributedString.Index = self.index(endIndex, offsetByCharacters: -n)
        
        removeSubrange(newEnd..<endIndex)
    }
    
    /// **Non‑mutating:** Returns a copy with the last *n* characters removed.
    /// - Parameter n: Number of characters to trim from the end.
    public func removingLastCharacters(_ n: Int) -> AttributedString {
        var result = self
        
        result.removeLastCharacters(n)
        
        return result
    }
}
