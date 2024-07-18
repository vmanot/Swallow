//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Foundation.NSEnumerator: Swift.IteratorProtocol {
    public typealias Element = Any
    
    public final func next() -> Element? {
        return nextObject()
    }
}
