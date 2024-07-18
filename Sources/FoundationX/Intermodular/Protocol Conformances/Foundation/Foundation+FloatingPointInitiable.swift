//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Foundation
import Swallow

extension Decimal: Swallow.FloatingPointInitiable {
    public init(_ value: NSDecimalNumber) {
        self = value as Decimal
    }
    
    public init(_ value: NSNumber) {
        self = value.decimalValue
    }
    
    public init(_ value: Float) {
        self.init(value as NSNumber)
    }
    
    public init(_ value: CGFloat) {
        self.init(CGFloat.NativeType(value))
    }
}
