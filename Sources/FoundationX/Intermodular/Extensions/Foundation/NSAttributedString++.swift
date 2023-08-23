//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
import AppKit
#endif
import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension NSAttributedString {
    public func splitIncludingSeparators(
        maxSplits: Int = .max,
        omittingEmptySubsequences: Bool = true,
        whereSeparator isSeparator: (Character) -> Bool
    ) -> [NSAttributedString] {
        let string = self.string
        let components: [Substring] = string.splitIncludingSeparators(
            maxSplits: maxSplits,
            omittingEmptySubsequences: omittingEmptySubsequences,
            whereSeparator: isSeparator
        )
        
        var result: [NSAttributedString] = []
        
        for component in components {
            let range = NSRange(component.bounds, in: string)
            
            result.append(attributedSubstring(from: range))
            
            let separatorRange = NSRange(location: (range.location + range.length) + 1, length: 1)
            
            if separatorRange.location < self.length {
                let separatorString = self.attributedSubstring(from: separatorRange)
                
                assert(separatorString.length == 1)
                assert(isSeparator(separatorString.string.first!))

                result.append(separatorString)
            }
        }
        
        assert(string.isEmpty == result.isEmpty)
        
        return result
    }
}

extension NSAttributedString {
    public func _attributedSubstringsWithAttributes(
        isolateAttachments: Bool
    ) -> [(string: NSAttributedString, attributes: [NSAttributedString.Key: Any])] {
        var result: [(string: NSAttributedString, attributes: [NSAttributedString.Key: Any])] = []
        let fullRange = NSRange(location: 0, length: length)
        
        self.enumerateAttributes(in: fullRange, options: []) { (attributes, range, stop) in
            let subString = self.attributedSubstring(from: range)

            result.append((string: subString, attributes: attributes))
        }
        
        var lastLocation = 0
        
        for (string, _) in result {
            if lastLocation < fullRange.location {
                let range = NSRange(location: lastLocation, length: fullRange.location - lastLocation)
                let subString = self.attributedSubstring(from: range)
                
                result.append((string: subString, attributes: [:]))
            }
            
            lastLocation += string.length
        }
        
        if lastLocation < fullRange.length {
            let range = NSRange(location: lastLocation, length: fullRange.length - lastLocation)
            let subString = self.attributedSubstring(from: range)
            result.append((string: subString, attributes: [:]))
        }
        
        if isolateAttachments {
            result = result.flatMap { (string, attributes) in
                string.splitIncludingSeparators(whereSeparator: {
                    $0 == Character._NSTextAttachment_character
                }).lazy.map {
                    ($0, attributes)
                }
            }
        }
        
        return result
    }
}

// MARK: - Helpers

#if canImport(AppKit) || canImport(UIKit) && !os(watchOS)
extension Character {
    public static var _NSTextAttachment_character: Character? {
        guard let scalar = UnicodeScalar(NSTextAttachment.character) else {
            assertionFailure()
            
            return nil
        }
        
        return Character(scalar)
    }
}
#else
extension Character {
    public static var _NSTextAttachment_character: Character? {
        nil
    }
}
#endif
