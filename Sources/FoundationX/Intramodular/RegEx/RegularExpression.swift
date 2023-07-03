//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct RegularExpression: Hashable, Initiable {
    public var pattern: String
    public var options: Options
    
    public init(pattern: String = "", options: Options = []) {
        self.pattern = pattern
        self.options = options
    }
    
    public init() {
        self.init(pattern: .init())
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pattern)
        hasher.combine(options.rawValue)
    }
}

extension RegularExpression {
    public var isEmpty: Bool {
        pattern.isEmpty
    }
    
    public var isValid: Bool {
        return (try? NSRegularExpression(pattern: pattern, options: options)).isNotNil
    }
    
    func modifyPattern(_ modify: (String) -> String) -> Self {
        .init(pattern: modify(pattern), options: options)
    }
}

// MARK: - Implementation

extension RegularExpression {
    public func matchRanges(in string: String) -> [Range<String.Index>] {
        (self as NSRegularExpression)
            .matches(in: string, range: NSRange(string.bounds, in: string))
            .map({ Range($0.range, in: string)! })
    }
    
    public func matchAndCaptureRanges(in string: String, options: NSRegularExpression.MatchingOptions = []) -> [(Range<String.Index>, [Range<String.Index>?])] {
        var result = [(Range<String.Index>, [Range<String.Index>?])]()
        
        let matches = (self as NSRegularExpression).matches(
            in: string,
            options: options,
            range: NSRange(string.bounds, in: string)
        )
        
        for match in matches {
            let matchedString = string[match.range]
            let captured = (1..<match.numberOfRanges).map(match.range(at:)).map({ Range.init($0, in: string) })
            
            result.append((matchedString.bounds, captured))
        }
        
        return result
    }
    
    public func matchAndCaptureSubstrings(in string: String) -> [(Substring, [Substring])] {
        var result = [(Substring, [Substring])]()
        
        let matches = (self as NSRegularExpression).matches(in: string, options: .reportCompletion, range: NSRange(string.bounds, in: string))
        
        for match in matches {
            let matchedString = string[match.range]
            let captured = (1..<match.numberOfRanges).map(match.range(at:)).map({ string[$0] })
            
            result.append((matchedString, captured))
        }
        
        return result
    }
}

// MARK: - API

extension RegularExpression {
    public static func oneOf(_ expressions: [Self]) -> Self {
        Self(
            pattern: expressions.map({ $0.groupIfNecessary().pattern }).interspersed(with: "|").joined(),
            options: expressions.reduce([], { $0.union($1.options) })
        )
        .groupIfNecessary()
    }
    
    public func or(_ expression: Self) -> Self {
        self.nonCaptureGroup()
            .modifyPattern({ $0.appending("|") })
            .append(expression)
            .nonCaptureGroup()
    }
    
    public func `repeat`(_ count: Int) -> Self {
        groupIfNecessary().modifyPattern({ $0.appending("{\(count)}") })
    }
    
    public func `repeat`() -> Self {
        groupIfNecessary().modifyPattern({ $0.appending("+") })
    }
    
    public func optional() -> Self {
        groupIfNecessary().modifyPattern({ $0.appending("?") })
    }
}

// MARK: - Conformances

extension RegularExpression: AdditionOperatable {
    @inlinable
    public static func + (lhs: RegularExpression, rhs: RegularExpression) -> RegularExpression {
        return .init(pattern: lhs.pattern.appending(rhs.pattern), options: lhs.options.union(rhs.options))
    }
    
    public func append(_ expression: Self) -> Self {
        self + expression
    }
    
    @inlinable
    public static func += (lhs: inout RegularExpression, rhs: RegularExpression) {
        lhs = lhs + rhs
    }
    
    @inlinable
    public static func + (lhs: RegularExpression, rhs: String) -> RegularExpression {
        lhs + .init(rhs)
    }
    
    @inlinable
    public static func += (lhs: inout RegularExpression, rhs: String) {
        lhs = lhs + rhs
    }
    
    @inlinable
    public static func + (lhs: String, rhs: RegularExpression) -> RegularExpression {
        .init(lhs) + rhs
    }
}

extension RegularExpression: CustomDebugStringConvertible {
    public var debugDescription: String {
        pattern.debugDescription
    }
}

extension RegularExpression: CustomStringConvertible {
    public var description: String {
        pattern.description
    }
}

extension RegularExpression: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
}

extension RegularExpression: LosslessStringConvertible {
    public init(_ text: String) {
        self.init(pattern: text)
    }
}

extension RegularExpression: ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSRegularExpression
    
    public static func bridgeFromObjectiveC(_ source: ObjectiveCType) throws -> Self {
        .init(pattern: source.pattern, options: source.options)
    }
    
    public func bridgeToObjectiveC() throws -> ObjectiveCType {
        try .init(pattern: pattern, options: options)
    }
}

extension RegularExpression: StringRepresentable {
    public var stringValue: String {
        pattern
    }
    
    public init(stringValue: String) {
        self.init(pattern: stringValue)
    }
}

// MARK: - API

infix operator =~: ComparisonPrecedence
infix operator !~: ComparisonPrecedence

extension RegularExpression {
    public static func =~ (lhs: String, rhs: RegularExpression) -> Bool {
        return lhs.matches(rhs)
    }
    
    public static func !~ (lhs: String, rhs: RegularExpression) -> Bool {
        return !(lhs =~ rhs)
    }
}
