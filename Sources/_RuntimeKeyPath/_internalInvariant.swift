//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftShims

/// Internal checks.
///
/// Internal checks are to be used for checking correctness conditions in the
/// standard library. They are only enable when the standard library is built
/// with the build configuration INTERNAL_CHECKS_ENABLED enabled. Otherwise, the
/// call to this function is a noop.
@usableFromInline @_transparent
internal func _internalInvariant(
    _ condition: @autoclosure () -> Bool, _ message: String = "",
    file: StaticString = #file, line: UInt = #line
) {
#if INTERNAL_CHECKS_ENABLED
    if !_fastPath(condition()) {
        fatalError(message, file: file, line: line)
    }
#endif
}

@usableFromInline @_transparent
internal func _internalInvariantFailure(
    _ message: String = "",
    file: StaticString = #file, line: UInt = #line
) -> Never {
    _internalInvariant(false, message, file: file, line: line)
    Builtin.conditionallyUnreachable()
}
