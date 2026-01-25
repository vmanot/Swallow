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
}
