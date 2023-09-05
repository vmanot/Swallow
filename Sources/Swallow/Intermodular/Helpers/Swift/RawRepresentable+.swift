//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol RawValueConvertible {
    associatedtype RawValue
    
    var rawValue: RawValue { get }
}

public protocol ThrowingRawValueConvertible {
    associatedtype RawValue
    
    var rawValue: RawValue { get throws }
}

public protocol MutableRawValueConvertible {
    associatedtype RawValue
    
    var rawValue: RawValue { get }
}

public protocol MutableRawRepresentable: MutableRawValueConvertible, RawRepresentable {
    var rawValue: RawValue { get set }
    
    init(rawValue: RawValue)
}
