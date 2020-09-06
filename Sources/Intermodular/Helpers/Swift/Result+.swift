//
// Copyright (c) Vatsal Manot
//

import Swift

extension Optional {
    public func unwrap<T, U: Error>(file: StaticString = #file, function: StaticString = #function, line: UInt = #line,  column: UInt = #column) throws -> T where Wrapped == Result<T, U> {
        return try unwrap(file: file, function: function, line: line, column: column).unwrap()
    }

    public func unwrap<T>(file: StaticString = #file, function: StaticString = #function, line: UInt = #line,  column: UInt = #column) throws -> T where Wrapped == Result<T, Error> {
        return try unwrap(file: file, function: function, line: line, column: column).unwrap()
    }
}

public protocol ResultInitiable {
    associatedtype ResultSuccessType
    associatedtype ResultFailureType: Error

    init(_: Result<ResultSuccessType, ResultFailureType>)
}

extension Result {
    public var comparison: ResultComparison {
        switch self {
        case .success:
            return .success
        case .failure:
            return .failure
        }
    }
}

public enum ResultComparison: Hashable {
    case success
    case failure

    public static func == <T, U>(lhs: Result<T, U>, rhs: ResultComparison) -> Bool {
        return lhs.comparison == rhs
    }

    public static func != <T, U>(lhs: Result<T, U>, rhs: ResultComparison) -> Bool {
        return lhs.comparison != rhs
    }
}
