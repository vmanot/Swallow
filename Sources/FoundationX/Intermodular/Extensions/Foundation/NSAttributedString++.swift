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

#if os(iOS)
extension NSAttributedString {
    public var containsAttachments: Bool {
        self.containsAttachments(in: stringBounds)
    }
}
#endif

extension NSAttributedString {
    @MainActor
    public convenience init?(html: String) throws {
        try self.init(
            data: try html.data(using: .utf16, allowLossyConversion: false).unwrap(),
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }
    
    public func appending(_ string: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        
        result.append(string)
        
        return result
    }
}

extension NSAttributedString {
    public var stringBounds: NSRange {
        NSRange(location: 0, length: length)
    }
}

extension NSAttributedString {
    public struct EnumerateAttributesSequence: Sequence {
        public typealias Element = (range: NSRange, attributes: [NSAttributedString.Key: Any])
        
        let _makeIterator: () -> Iterator
        
        public struct Iterator: IteratorProtocol {
            let attributedString: NSAttributedString
            let attributeKey: NSAttributedString.Key?
            
            private var index: Int
            
            public init(
                attributedString: NSAttributedString,
                attribute: NSAttributedString.Key?
            ) {
                self.attributedString = attributedString
                self.attributeKey = attribute
                self.index = 0
            }
            
            public mutating func next() -> Element? {
                let currentIndex = index
                
                guard currentIndex < attributedString.length else {
                    return nil
                }
                                       
                let range: NSRange
                let attributes: [NSAttributedString.Key: Any]
                
                if let attributeKey {
                    var currentRange: NSRange = NSRange()
                    
                    let attribute = attributedString.attribute(
                        attributeKey,
                        at: index,
                        longestEffectiveRange: &currentRange,
                        in: NSRange(location: currentIndex, length: attributedString.length - currentIndex)
                    )
                    
                    index = NSMaxRange(currentRange)
                    
                    if attributeKey == .attachment, attribute == nil, index < attributedString.length {
                        if let _attribute = attributedString.attribute(
                            attributeKey,
                            at: index,
                            effectiveRange: nil
                        ) {
                            defer {
                                self.index = index + 1
                            }
                            
                            return (NSRange(location: index, length: 1), [.attachment: _attribute])
                        }
                    }

                    range = currentRange

                    attributes = attribute.map({ [attributeKey: $0] }) ?? [:]
                } else {
                    var currentRange: NSRange = NSRange()

                    attributes = attributedString.attributes(
                        at: index,
                        longestEffectiveRange: &currentRange,
                        in: NSRange(location: currentIndex, length: attributedString.length - currentIndex)
                    )
                    
                    index = NSMaxRange(currentRange)
                    
                    range = currentRange
                }
                                
                guard index != currentIndex else {
                    assertionFailure()
                    
                    return nil
                }
                
                if let attributeKey {
                    guard attributes[attributeKey] != nil else {
                        return nil
                    }
                }
                
                assert((range.location + range.length) <= attributedString.length)
                
                return (range: range, attributes: attributes)
            }
        }
        
        public consuming func makeIterator() -> Iterator {
            _makeIterator()
        }
    }
    
    public var attributes: EnumerateAttributesSequence {
        EnumerateAttributesSequence {
            .init(attributedString: self, attribute: nil)
        }
    }
    
    public func enumerateAttributes(
        options: NSAttributedString.EnumerationOptions = [],
        using block: ([NSAttributedString.Key: Any], NSRange, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        enumerateAttributes(in: stringBounds, options: options, using: block)
    }
    
    public func enumerateSequence(
        for attribute: NSAttributedString.Key? = nil
    ) -> EnumerateAttributesSequence {
        EnumerateAttributesSequence {
            .init(attributedString: self, attribute: attribute)
        }
    }
}
    
extension NSAttributedString {
    public func splitIncludingSeparators(
        maxSplits: Int = .max,
        omittingEmptySubsequences: Bool = true,
        whereSeparator isSeparator: (Character) -> Bool
    ) -> [NSAttributedString] {
        let string = self.string
        let components: [Substring] = string.split(
            maxSplits: maxSplits,
            omittingEmptySubsequences: omittingEmptySubsequences,
            whereSeparator: isSeparator
        )
        
        var result: [NSAttributedString] = []
        
        func validateSeparator(_ separator: NSAttributedString) {
            guard let separatorCharacter = separator.string.first else {
                assertionFailure()
                
                return
            }
            
            assert(separator.length == 1)
            assert(isSeparator(separatorCharacter))
            
            if separatorCharacter == Character._NSTextAttachment_character {
                assert(separator.attributes.first?.attributes[.attachment] != nil)
            }
        }
        
        for component in components {
            let range = NSRange(component.bounds, in: string)
            
            result.append(attributedSubstring(from: range))
            
            let separatorRange = NSRange(location: range.location + range.length, length: 1)
            
            if separatorRange.location < self.length {
                let separator = self.attributedSubstring(from: separatorRange)
                
                validateSeparator(separator)

                result.append(separator)
            }
        }
        
        if let last = string.last, isSeparator(last) {
            let separatorRange = NSRange(string.lastIndex!..<string.endIndex, in: string)
            let separator = self.attributedSubstring(from: separatorRange)
            
            validateSeparator(separator)

            result.append(separator)
        }
            
        assert(string.isEmpty == result.isEmpty)
        
        return result
    }
}

extension NSAttributedString {
    public func _characterWideAttributedStrings() -> [NSAttributedString] {
        var attributedStrings: [NSAttributedString] = []
        let length = self.length
        
        for i in 0..<length {
            let range = NSRange(location: i, length: 1)
            let attributedSubstring = self.attributedSubstring(from: range)
            attributedStrings.append(attributedSubstring)
        }
        
        return attributedStrings
    }

    public func _enumerateAttributesAndDump(
        forRange range: NSRange? = nil,
        options: NSAttributedString.EnumerationOptions = []
    ) -> [(range: NSRange, attributes: [NSAttributedString.Key: Any])] {
        var result: [(range: NSRange, attributes: [NSAttributedString.Key: Any])] = []
        
        enumerateAttributes(in: range ?? stringBounds, options: options) { attributes, range, stop in
            result.append((range, attributes))
        }
        
        return result
    }

    public func _attributedSubstringsWithAttributes(
        isolateAttachments: Bool
    ) -> [(string: NSAttributedString, attributes: [NSAttributedString.Key: Any])] {
        var result: [(string: NSAttributedString, attributes: [NSAttributedString.Key: Any])] = []
        let fullRange = NSRange(location: 0, length: length)
        
        self.enumerateAttributes(in: fullRange, options: [.longestEffectiveRangeNotRequired]) { (attributes, range, stop) in
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
