//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation

extension POSIXErrorCode {
    public static var last: POSIXErrorCode! {
        get {
            return POSIXErrorCode(rawValue: errno)
        } set {
            errno = newValue.map(keyPath: \.rawValue) ?? 0
        }
    }
}
