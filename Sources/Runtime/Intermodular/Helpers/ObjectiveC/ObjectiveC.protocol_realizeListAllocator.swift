//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public func protocol_realizeListAllocator<T: Wrapper>(_ p: Protocol, with f: ((Protocol, Bool, Bool, UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<T.Value>?), _ x: (Bool, Bool)) -> AnyRandomAccessCollection<T> {
    var count: UInt32 = 0
    let baseAddress = f(p, x.0, x.1, &count)
    
    return .init(AutodeallocatingUnsafeBufferPointer(start: baseAddress, count: count).lazy.map(T.init))
}

public func protocol_realizeListAllocator<T: Wrapper>(_ p: Protocol, with f: ((Protocol, UnsafeMutablePointer<UInt32>?, Bool, Bool) -> UnsafeMutablePointer<T.Value>?), _ x: (Bool, Bool)) -> AnyRandomAccessCollection<T> {
    var count: UInt32 = 0
    let baseAddress = f(p, &count, x.0, x.1)
    
    return .init(AutodeallocatingUnsafeBufferPointer(start: baseAddress, count: count).lazy.map(T.init))
}
