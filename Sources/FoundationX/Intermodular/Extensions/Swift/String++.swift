//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension String {
    @_disfavoredOverload
    public init?<BP: RawBufferPointer>(
        bytesNoCopy bytes: BP,
        encoding: String.Encoding,
        freeWhenDone: Bool
    ) {
        guard !bytes.isEmpty else {
            return nil
        }
        
        self.init(
            bytesNoCopy: .init(bitPattern: bytes.baseAddress!),
            length: numericCast(bytes.count),
            encoding: encoding,
            freeWhenDone: freeWhenDone
        )
    }
}

extension String {
    public func substring(withRange range: NSRange) -> Substring {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        
        return self[start..<end]
    }
}

extension String {
    static public func random(length: UInt, in characterSet: CharacterSet = .alphanumerics) -> String {
        let letters = characterSet.value.map(\.self)
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension String {
    public static func _pluralize(
        _ string: String,
        count: Int
    ) -> AttributedString {
        _memoize(uniquingWith: (string, count)) {
            var string = AttributedString(localized: String.LocalizationValue(stringLiteral: string))
            
            var morphology = Morphology()
            let number: Morphology.GrammaticalNumber
            
            switch count {
                case 0:
                    number = .zero
                case 1:
                    number = .singular
                default:
                    number = .plural
            }
            
            morphology.number = number
            
            string.inflect = InflectionRule(morphology: morphology)
            
            let formattedResult = string.inflected()
            
            return formattedResult
        }
    }
}
