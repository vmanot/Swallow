//
// Copyright (c) Vatsal Manot
//

import Swift

/// Unconditionally throws an error and stops execution.
public func fatalError(
    _ error: Error,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) -> Never {
    try! error.throw()
}
