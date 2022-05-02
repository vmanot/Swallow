//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@propertyWrapper
public struct LosslessNumber<N: Number>: Decodable, Equatable, Hashable {
    public let wrappedValue: N
    
    public init(wrappedValue: N) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        wrappedValue = try Result(
            try .init(from: decoder),
            or: try .lossless(from: try AnyNumber(from: decoder))
        )
        .get()
    }
}

@propertyWrapper
public struct LosslessNumberRepresentable<T: RawRepresentable & Hashable>: Decodable, Hashable where T.RawValue: Number {
    public let wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        wrappedValue = try T(
            rawValue: try Result(
                try .init(from: decoder),
                or: try .lossless(from: try AnyNumber(from: decoder))
            )
            .get()
        )
        .unwrap()
    }
}

@propertyWrapper
public struct OptionalLosslessNumber<N: Number>: Decodable, Hashable {
    public let wrappedValue: Optional<N>
    
    public init(wrappedValue: Optional<N>) {
        self.wrappedValue = wrappedValue
    }
    
    public init() {
        self.init(wrappedValue: nil)
    }
    
    public init(from decoder: Decoder) throws {
        if (try? decoder.decodeNil()) ?? false {
            self.wrappedValue = nil
        } else {
            wrappedValue = try Result(
                try .init(from: decoder),
                or: try .lossless(from: try AnyNumber(from: decoder))
            )
            .get()
        }
    }
}
