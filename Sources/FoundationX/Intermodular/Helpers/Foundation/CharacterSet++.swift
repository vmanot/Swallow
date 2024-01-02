//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension CharacterSet {
    public init(_ characters: some Sequence<Character>) {
        self.init(charactersIn: characters.reduce(into: "", +=))
    }
}

extension CharacterSet {
    /// Characters that need to be escaped for zsh.
    public static let _zshIllegalUnescaped: CharacterSet = CharacterSet(charactersIn: "!#$^&*?[(){}<>~;'\"`|=\\ \t\n")
    
    /// Quotation delimeters.
    public static let quotationDelimiters = CharacterSet(charactersIn: "\"”'“’‘″′„‚‶‵")
}
