//
//  String++.swift
//  Swallow
//
//  Created by Yanan Li on 2026/1/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension String {
    /// Source text for a non-interpolated Swift string literal with this value.
    public var swiftStringLiteralSource: String {
        StringLiteralExprSyntax(content: self).trimmedDescription
    }
}
