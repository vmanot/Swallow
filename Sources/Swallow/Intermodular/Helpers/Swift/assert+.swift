//
// Copyright (c) Vatsal Manot
//

import Swift

@inline(__always)
@_transparent
@_disfavoredOverload
public func assert(
    _ condition: @autoclosure () throws -> Bool,
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        let condition = try condition()
        
        Swift.assert(condition, message(), file: file, line: line)
    } catch {
        assertionFailure(error)
    }
}

@inlinable
public func assert(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line,
    _ body: () -> Bool
) {
    Swift.assert(body(), message(), file: file, line: line)
}

public func _internalInvariant(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) {
    assert(condition(), message(), file: file, line: line)
}
