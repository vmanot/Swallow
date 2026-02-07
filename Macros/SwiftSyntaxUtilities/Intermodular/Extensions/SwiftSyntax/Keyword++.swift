//
//  Keyword++.swift
//  crowbar
//
//  Created by Yanan Li on 2025/9/11.
//

import Foundation
@_spi(RawSyntax) import SwiftSyntax

extension Keyword {
    public init(_ str: String) throws {
        var str = str
        self = try str.withSyntaxText { text in
            if let keyword = Keyword(text) {
                return keyword
            } else {
                throw UnableToFindKeyword()
            }
        }
    }
    
    struct UnableToFindKeyword: Error { }
}
