//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Swift

/// Unconditionally throws an error and stops execution.
@_transparent
public func fatalError(
    _ error: Error,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) -> Never {
    try! error.throw()
}

infix operator !! : NilCoalescingPrecedence

@_transparent
public func !!<T>(
    lhs: T?,
    rhs: String
) -> T {
    guard let lhs else {
        fatalError(CustomStringError(description: rhs))
    }
    
    return lhs
}

@_transparent
public func !!<T>(
    lhs: T?,
    rhs: some Error
) -> T {
    guard let lhs else {
        fatalError(rhs)
    }
    
    return lhs
}
