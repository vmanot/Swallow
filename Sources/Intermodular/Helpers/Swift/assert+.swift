//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func assert(_ body: (() -> Bool)) {
    Swift.assert(body())
}

public func _internalInvariant(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) {
    assert(condition(), message(), file: file, line: line)
}
