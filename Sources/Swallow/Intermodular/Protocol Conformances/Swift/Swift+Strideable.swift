//
// Copyright (c) Vatsal Manot
//

import Swift

extension OpaquePointer: Swift.Strideable {
    public typealias Stride = Int

    public func distance(to other: OpaquePointer) -> Stride {
        return unsafePointerRepresentation.distance(to: other.unsafePointerRepresentation)
    }
    
    public func advanced(by stride: Stride) -> OpaquePointer {
        return unsafePointerRepresentation.advanced(by: stride).opaquePointerRepresentation
    }
}
