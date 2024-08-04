//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@objc(_Swallow_RuntimeTypeDiscovery)
open class _RuntimeTypeDiscovery: NSObject {
    open class var type: Any.Type {
        assertionFailure()
        
        return Never.self
    }
}
