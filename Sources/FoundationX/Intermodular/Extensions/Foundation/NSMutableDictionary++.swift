//
// Copyright (c) Vatsal Manot
//

import CoreFoundation
import Foundation
import Swallow

extension NSMutableDictionary {
    @objc public dynamic class func mutableDictionaryUsingWeakReferences(
        withCapacity capacity: Int = 0
    ) -> NSMutableDictionary {
        var keyCallbacks = kCFTypeDictionaryKeyCallBacks
        var valueCallbacks = kCFTypeDictionaryValueCallBacks
        
        valueCallbacks.retain = nil
        valueCallbacks.release = nil
        
        return CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &valueCallbacks)
    }
}
