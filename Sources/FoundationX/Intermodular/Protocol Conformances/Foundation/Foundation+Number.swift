//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Decimal: Swallow.Continuous, Swallow.Signed, Swallow.Number {
    @inlinable
    public var isNegative: Bool {
        return _isNegative.toBool()
    }
    
    @inlinable
    public init(_opaque_uncheckedValue value: _opaque_Number) {
        self = value.toDecimal()
    }
    
    @inlinable
    public init<N: _opaque_Number>(unchecked value: N) {
        self = value.toDecimal()
    }
}
