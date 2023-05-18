//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension BufferPointer where Self: InitiableBufferPointer & RawBufferPointer {
    public init(unmanaged data: NSData) {
        self.init(start: data.bytes.unsafeMutablePointerRepresentation, count: data.count)
    }
}
