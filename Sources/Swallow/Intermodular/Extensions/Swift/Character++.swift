//
// Copyright (c) Vatsal Manot
//

import Swift

extension Character {
    public static let zeroWidthSpace = Character("\u{200B}")
    public static let backtick: Self = "`"
    public static var newline: Self = "\n"
    public static let quotationMark: Self = "\""
}

extension String {
    public static var backtick: Self {
        Self(Character.backtick)
    }
    
    public static var newline: Self {
        Self(Character.newline)
    }
    
    public static var quotationMark: Self {
        Self(Character.quotationMark)
    }
}

extension Character {
    /// Creates a new character from a single UTF-16 code unit.
    public init?(utf16CodeUnit: UTF16.CodeUnit) {
        guard let scalar = Unicode.Scalar(utf16CodeUnit) else {
            return nil
        }
        
        self.init(scalar)
    }
}
