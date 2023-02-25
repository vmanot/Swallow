//
// Copyright (c) Vatsal Manot
//

import Swift

extension Character {
    public static var newLine: Character {
        return "\n"
    }
    
    /// Creates a new character from a single UTF-16 code unit.
    public init?(utf16CodeUnit: UTF16.CodeUnit) {
        guard let scalar = Unicode.Scalar(utf16CodeUnit) else {
            return nil
        }
        
        self.init(scalar)
    }
}
