//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension NSNumber {
    public func downcast() -> Any {
        if let result = self as? NSDecimalNumber {
            return result as Decimal
        }
        
        let type = String(cString: objCType)
        
        switch type {
            case "c":
                return self as! CChar
            case "i":
                return self as! CInt
            case "s":
                return self as! CShort
            case "l":
                return self as! CLong
            case "ll":
                return self as! CLongLong
            case "C":
                return self as! CUnsignedChar
            case "I":
                return self as! CUnsignedInt
            case "S":
                return self as! CUnsignedShort
            case "L":
                return self as! CUnsignedLong
            case "Q":
                return self as! CUnsignedLongLong
            case "f":
                return self as! CFloat
            case "d":
                return self as! Double
            case "B":
                return self as! CBool
            default: do {
                return self
            }
        }
    }
}
