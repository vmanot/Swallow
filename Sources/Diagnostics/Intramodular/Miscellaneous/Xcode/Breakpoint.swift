//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow
import os

public struct Breakpoint {
    @_transparent
    public static func trigger() {
        if _isDebugAssertConfiguration {
            raise(SIGTRAP)
        }
    }

    @_spi(Internal)
    @_transparent
    public static func _altTrigger() {
        _ = Fail<Void, _GenericBreakpointError>(error: _GenericBreakpointError.some)
            .breakpointOnError()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
    
    @_spi(Internal)
    public enum _GenericBreakpointError: Error {
        case some
    }
}
