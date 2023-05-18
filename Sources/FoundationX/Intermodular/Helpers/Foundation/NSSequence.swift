//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@objc protocol NSSequence {
    func objectEnumerator() -> NSEnumerator
}
