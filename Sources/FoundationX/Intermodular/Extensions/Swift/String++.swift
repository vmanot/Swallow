//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension String {
    public init?<BP: RawBufferPointer>(bytesNoCopy bytes: BP, encoding: String.Encoding, freeWhenDone: Bool) {
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
    public func contains(only characterSet: CharacterSet) -> Bool {
        CharacterSet(charactersIn: self).isSubset(of: characterSet)
    }
    
    public func substring(withRange range: NSRange) -> Substring {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        
        return self[start..<end]
    }

    public func removingCharacters(in characterSet: CharacterSet) -> String {
        String(String.UnicodeScalarView(unicodeScalars.filter({ !characterSet.contains($0) })))
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension String {
    public static func _pluralize(
        _ string: String.LocalizationValue,
        count: Int
    ) -> AttributedString {
        var string = AttributedString(localized: string)

        return _memoize(uniquingWith: (string, count)) {
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
