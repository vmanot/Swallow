//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct PredicateError: Error, Hashable, CustomDebugStringConvertible {
    internal enum _Error: Hashable, Sendable {
        case undefinedVariable
        case forceUnwrapFailure(String?)
        case forceCastFailure(String?)
        case invalidInput(String?)
    }
    
    private let _error: _Error
    
    internal init(_ error: _Error) {
        _error = error
    }
    
    public var debugDescription: String {
        switch _error {
            case .undefinedVariable:
                return "Encountered an undefined variable"
            case .forceUnwrapFailure(let string):
                return string ?? "Attempted to force unwrap a nil value"
            case .forceCastFailure(let string):
                return string ?? "Failed to cast a value to the desired type"
            case .invalidInput(let string):
                return string ?? "The inputs to this expression are invalid"
        }
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch lhs._error {
            case .undefinedVariable:
                return rhs == .undefinedVariable
            case .forceCastFailure(_):
                if case .forceCastFailure(_) = rhs._error {
                    return true
                }
                return false
            case .forceUnwrapFailure(_):
                if case .forceUnwrapFailure(_) = rhs._error {
                    return true
                }
                return false
            case .invalidInput(_):
                if case .invalidInput(_) = rhs._error {
                    return true
                }
                return false
        }
    }
    
    public static let undefinedVariable = Self(.undefinedVariable)
    public static let forceUnwrapFailure = Self(.forceUnwrapFailure(nil))
    public static let forceCastFailure = Self(.forceCastFailure(nil))
    public static let invalidInput = Self(.invalidInput(nil))
}
