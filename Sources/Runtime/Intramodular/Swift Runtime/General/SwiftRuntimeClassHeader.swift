//
// Copyright (c) Vatsal Manot
//

import Swallow

struct SwiftRuntimeClassHeader: Hashable {
    var isa: UnsafeRawPointer?
    var strongRetainCounts: Int32
    var weakRetainCounts: Int32
    
    static func of(_ object: inout AnyObject) -> SwiftRuntimeClassHeader {
        return withUnsafePointer(to: &object) { pointer in
            return pointer.withMemoryRebound(to: UnsafePointer.self, capacity: 1) {
                return $0.pointee.pointee
            }
        }
    }
}
