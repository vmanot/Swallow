//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSDecimalNumber {
    public typealias Handler = NSDecimalNumberHandler
}

extension NSDecimalNumber {
    public func remainder(dividingBy divisor: NSDecimalNumber) -> NSDecimalNumber {
        let quotient = dividing(by: divisor, withBehavior: Handler(
            roundingMode: (isSignMinus != divisor.isSignMinus ? .up : .down),
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        ))
        
        let result = self - (quotient * divisor)
        
        return divisor.isSignMinus
            ? (result * .init(mantissa: 1, exponent: 0, isNegative: true))
            : result
    }
}
