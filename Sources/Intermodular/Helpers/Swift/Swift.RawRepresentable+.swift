//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol RawValueConvertible {
    associatedtype RawValue

    var rawValue: RawValue { get }
}

public protocol MutableRawValueConvertible {
    associatedtype RawValue

    var rawValue: RawValue { get }
}

public protocol MutableRawRepresentable: MutableRawValueConvertible, RawRepresentable2 {
    var rawValue: RawValue { get set }
    
    init(rawValue: RawValue)
}
