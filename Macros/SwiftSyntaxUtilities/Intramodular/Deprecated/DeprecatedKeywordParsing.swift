//
// Copyright (c) Vatsal Manot
//

@_spi(RawSyntax) import SwiftSyntax

extension Keyword {
    @available(*, deprecated, message: "Match the finite Keyword cases required by the macro instead of accepting arbitrary source text.")
    public init(
        _ source: String
    ) throws {
        var source = source

        self = try source.withSyntaxText { text in
            guard let keyword = Keyword(text) else {
                throw InvalidKeywordSource()
            }

            return keyword
        }
    }
}

private struct InvalidKeywordSource: Error { }
