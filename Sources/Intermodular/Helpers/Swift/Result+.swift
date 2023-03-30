//
// Copyright (c) Vatsal Manot
//

import Swift

// MARK: - Codable Representation

extension Result where Success: Codable, Failure: Codable {
    public struct _CodableRepresentation: Codable {
        public let success: Success?
        public let failure: Failure?
        
        public init(from result: Result) {
            switch result {
                case .success(let success):
                    self.success = success
                    self.failure = nil
                case .failure(let failure):
                    self.success = nil
                    self.failure = failure
            }
        }
    }
    
    public init(_ representation: _CodableRepresentation) {
        self = representation.success.map({ Result.success($0) }) ?? Result.failure(representation.failure!)
    }
}

extension Result._CodableRepresentation: Equatable where Success: Equatable, Failure: Equatable {
    
}

extension Result._CodableRepresentation: Hashable where Success: Hashable, Failure: Hashable {
    
}

// MARK: - ResultInitiable

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

// MARK: - ResultComparison

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
