//
// Copyright (c) Vatsal Manot
//

import Swift

extension Bool: EitherRepresentable {
    public typealias EitherValue = Either<True.Type, False.Type>
    
    public var eitherValue: EitherValue {
        self ? .left(True.self) : .right(False.self)
    }
    
    public init(_ eitherValue: EitherValue) {
        self = eitherValue.isLeft ? true : false
    }
}

extension Result: EitherRepresentable {
    public typealias EitherValue = Either<Success, Failure>
    
    public var eitherValue: EitherValue {
        switch self {
            case .success(let value):
                return .left(value)
            case .failure(let error):
                return .right(error)
        }
    }
    
    public init(_ eitherValue: EitherValue) {
        switch eitherValue {
            case .left(let value):
                self = .success(value)
            case .right(let error):
                self = .failure(error)
        }
    }
}

// MARK: - SwiftUI Additions

#if canImport(SwiftUI)
import SwiftUI

extension Binding {
    public func unwrapLeft<L, R>(
        default defaultValue: L
    ) -> Binding<L> where Value == Either<L, R> {
        .init(
            get: {
                self.wrappedValue.leftValue ?? defaultValue
            },
            set: {
                self.wrappedValue = .left($0)
            }
        )
    }
    
    public func unwrapRight<L, R>(
        default defaultValue: R
    ) -> Binding<R> where Value == Either<L, R> {
        .init(
            get: {
                self.wrappedValue.rightValue ?? defaultValue
            },
            set: {
                self.wrappedValue = .right($0)
            }
        )
    }
}
#endif
