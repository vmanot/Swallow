//
//  OperatorSpecifier.swift
//  crowbar
//
//  Created by Yanan Li on 2025/8/3.
//

import SwiftSyntax

public enum OperatorSpecifier: String, CaseIterable, Comparable {
    case `prefix`
    case `infix`
    case `postfix`
    
    public var keyworks: Keyword {
        switch self {
        case .prefix: return .prefix
        case .infix: return .infix
        case .postfix: return .postfix
        }
    }
    
    public static func < (
        lhs: OperatorSpecifier,
        rhs: OperatorSpecifier
    ) -> Bool {
        let lhs = Self.allCases.firstIndex(of: lhs)!
        let rhs = Self.allCases.firstIndex(of: rhs)!
        
        return lhs < rhs
    }
}
