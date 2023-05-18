//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

extension POSIXError {
    public static var last: POSIXError! {
        get {
            return Code.last.map({ .init($0) })
        } set {
            Code.last = newValue?.code
        }
    }
}
