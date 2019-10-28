//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
@inline(__always)
public func assert(_ f: (() -> Bool)) {
    return Swift.assert(f())
}

public func _internalInvariant(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
    assert(condition(), message(), file: file, line: line)
}
