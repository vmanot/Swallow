//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension CharacterSet {
    public static let quotationDelimiters = CharacterSet(charactersIn: "\"”'“’‘″′„‚‶‵")
    
    public init(_ characters: some Sequence<Character>) {
        self.init(charactersIn: characters.reduce(into: "", +=))
    }
}
