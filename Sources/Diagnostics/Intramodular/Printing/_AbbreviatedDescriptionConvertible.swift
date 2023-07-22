//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftUI

public protocol _AbbreviatedDescriptionConvertible {
    var _abbreviatedDescription: String { get }
}

// MARK: - Implemented Conformances

extension UUID: _AbbreviatedDescriptionConvertible {
    public var _abbreviatedDescription: String {
        let string = uuidString.replacingOccurrences(of: "-", with: "")
        
        return "\(string.prefix(4))...\(string.suffix(4))"
    }
}
