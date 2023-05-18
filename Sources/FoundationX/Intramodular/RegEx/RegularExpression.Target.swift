//
// Copyright (c) Vatsal Manot
//

import Foundation

extension RegularExpression {
    public indirect enum Target {
        case startOfLine
        case endOfLine
        case singleCharacter
        case singleNumber
        case alphanumericCharacter
        case englishAlphabet
        case wordBoundary
        case tabSpace
        case lineBreak
        case character(Character)
        case characterSet(CharacterSet)
        case string(String)
        
        case zeroOrOne(Self)
        case zeroOrMore(Self)
        case oneOrMore(Self)
        case nonGreedy(Self)
        
        case anyOneOf([RegularExpression])
        case not(RegularExpression)
        case notTheseCharacters(String)
        
        case digitsInRange(ClosedRange<Int>)
        
        public static var anything: Self {
            .zeroOrMore(.singleCharacter)
        }
        
        public static var something: Self {
            .oneOrMore(.singleCharacter)
        }
        
        public static var word: Self {
            .oneOrMore(.alphanumericCharacter)
        }
    }
}

// MARK: - Conformances

extension RegularExpression.Target: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension RegularExpression.Target {
    public var rawValue: String {
        switch self {
            case .startOfLine:
                return "^"
            case .endOfLine:
                return "$"
            case .singleCharacter:
                return "."
            case .singleNumber:
                return "\\d"
            case .alphanumericCharacter:
                return "\\w"
            case .englishAlphabet:
                return "[A-Za-z]"
            case .wordBoundary:
                return "\\b"
            case .tabSpace:
                return "\t"
            case .lineBreak:
                return RegularExpression("\n").or(.init("\r\n")).stringValue
            case .character(let value):
                return String(value).sanitizedForRegularExpression
            case .characterSet(let value):
                return String(value.value).sanitizedForRegularExpression
            case .string(let value):
                return value.sanitizedForRegularExpression
                
            case .zeroOrOne(let target):
                return target.rawValue + "?"
            case .zeroOrMore(let target):
                return target.rawValue + "*"
            case .oneOrMore(let target):
                return target.rawValue + "+"
            case .nonGreedy(let target):
                return target.rawValue + "?"
                
            case .anyOneOf(let expressions):
                return "(?:".appending(expressions.map({ $0.groupIfNecessary().pattern }).joined(separator: "|")).appending(")")
            case .not(let expression):
                return "(?!".appending(expression.pattern).appending(")")
            case .notTheseCharacters(let value):
                return "[^\(value.sanitizedForRegularExpression)]"
                
            case .digitsInRange(let range):
                return "\\d{\(range.lowerBound),\(range.upperBound)}"
        }
    }
}

// MARK: - API

extension RegularExpression {
    public func match(_ target: RegularExpression.Target) -> RegularExpression {
        self + .init(pattern: target.rawValue)
    }
    
    @_disfavoredOverload
    public func match(_ expression: RegularExpression) -> RegularExpression {
        self + expression.nonCaptureGroup()
    }
    
    public func match(_ closure: ((RegularExpression) -> RegularExpression)) -> RegularExpression {
        match(closure(.init()))
    }
    
    public func or(_ target: RegularExpression.Target) -> RegularExpression {
        or(RegularExpression().match(target))
    }
    
    public func match(_ options: [RegularExpression.Target]) -> RegularExpression {
        RegularExpression.oneOf(options.map(RegularExpression().match(_:)))
    }
}

// MARK: - Helpers

fileprivate extension String {
    var sanitizedForRegularExpression: String {
        NSRegularExpression.escapedPattern(for: self)
    }
    
    func wrappedInNonCaptureGroup() -> String {
        "(?:" + self + ")"
    }
}
