//
// Copyright (c) Vatsal Manot
//

import Foundation
import Darwin
import Swallow

extension Int32 {
    public func toPOSIXResultCode() -> POSIXResultCode? {
        return POSIXResultCode(rawValue: self)
    }
    
    public func toPOSIXError() -> POSIXError? {
        return toPOSIXResultCode().flatMap(POSIXError.init(promoting:))
    }
    
    @discardableResult
    public func throwingAsPOSIXErrorIfNecessary() throws -> Int32 {
        try toPOSIXError()?.throw()
        
        return self
    }
}
