//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol Precisionable {
    associatedtype Precision
}

// MARK: - API

public struct ArbitraryPrecision<T: Precisionable> {
    public let base: T
    public let precision: T.Precision
    
    public init(_ base: T, precision: T.Precision) throws {
        self.base = base
        self.precision = precision
    }
}

extension ArbitraryPrecision: Codable where T: Codable, T.Precision: Codable {
    
}

extension ArbitraryPrecision: Equatable where T: Equatable, T.Precision: Equatable {
    
}

extension ArbitraryPrecision: Hashable where T: Hashable, T.Precision: Hashable {
    
}
