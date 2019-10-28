//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public protocol InitiableMutableBufferPointer: InitiableBufferPointer, MutableBufferPointer {
    init(mutating _: UnsafeBufferPointer<Element>)
}

extension InitiableMutableBufferPointer {
    public init<BP: ConstantBufferPointer>(mutating bufferPointer: BP) where BP.Element == Element {
        self.init(start: BaseAddressPointer(mutating: bufferPointer.baseAddress), count: bufferPointer.count)
    }
}
