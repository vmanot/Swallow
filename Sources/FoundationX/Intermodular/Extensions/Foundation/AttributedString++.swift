//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension AttributedString {
    public mutating func insert(
        _ text: AttributedString,
        atCharacterOffset offset: Int
    ) {
        insert(text, at: self.index(startIndex, offsetByCharacters: offset))
    }
}
