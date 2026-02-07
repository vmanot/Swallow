//
//  AccessorSpecifier.swift
//  crowbar
//
//  Created by Yanan Li on 2025/8/3.
//

import SwiftSyntax

public enum AccessorSpecifier: String, CaseIterable {
    case `get`
    case `set`
    
    public var keyword: Keyword {
        switch self {
        case .get:
            return .get
        case .set:
            return .set
        }
    }
}
