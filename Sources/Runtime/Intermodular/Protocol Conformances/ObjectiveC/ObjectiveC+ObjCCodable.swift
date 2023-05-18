//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCClass: ObjCCodable {
    public var objCTypeEncoding: ObjCTypeEncoding {
        return .init("{\(name)=#}")
    }
    
    public init(
        decodingObjCValueFromRawBuffer buffer: UnsafeMutableRawPointer?,
        encoding: ObjCTypeEncoding
    ) {
        self = .init(buffer!.assumingMemoryBound(to: AnyClass.self).pointee)
    }
    
    public func encodeObjCValueToRawBuffer() -> UnsafeMutableRawPointer {
        return .init(UnsafeMutablePointer.allocate(initializingTo: self))
    }
}
