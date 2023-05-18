//
// Copyright (c) Vatsal Manot
//

import CoreFoundation
import Foundation
import Swallow

extension NSMutableArray {
    public class func mutableArrayUsingWeakReferences(withCapicty capacity: Int = 0) -> NSMutableArray {
        var callbacks = CFArrayCallBacks()
        
        callbacks.retain = nil
        callbacks.release = nil
        
        return CFArrayCreateMutable(kCFAllocatorDefault, capacity, &callbacks)
    }
}
