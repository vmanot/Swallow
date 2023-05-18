//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Thread {
    public subscript(_ key: Any) -> Any? {
        get {
            return threadDictionary[key]
        } set {
            threadDictionary[key] = newValue
        }
    }
}
