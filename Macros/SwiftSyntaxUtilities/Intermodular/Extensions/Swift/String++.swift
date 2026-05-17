//
//  String++.swift
//  Swallow
//
//  Created by Yanan Li on 2026/1/25.
//

import Foundation

extension String {
    public var swiftIdentifierToken: String {
        if isValidSwiftIdentifier(for: .variableName) {
            return self
        } else {
            return "`\(self)`"
        }
    }

    public var swiftStringLiteralExpression: String {
        debugDescription
    }

    public var swiftFinalMemberName: String? {
        split(separator: ".").last.map(String.init)
    }

    public var swiftMemberBaseExpression: String? {
        guard let finalMemberName = swiftFinalMemberName else {
            return nil
        }

        let suffix = ".\(finalMemberName)"

        guard hasSuffix(suffix) else {
            return nil
        }

        return String(dropLast(suffix.count))
    }
}
