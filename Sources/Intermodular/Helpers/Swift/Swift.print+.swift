//
// Copyright (c) Vatsal Manot
//

import Swift

/// A variant of `print` suitable for easy functional composition.
@_disfavoredOverload
public func print<T>(_ item: T) {
    Swift.print(item)
}

public func unexpected(_ message: String? = nil,
                       file: StaticString = #file,
                       function: StaticString = #function,
                       line: UInt = #line) {
    if let message = message {
        print("\(message), file: \(file), function: \(function), line: \(line)")
    } else {
        print("Unexpected execution at file: \(file), function: \(function), line: \(line)")
    }
}


/// A function used to mark the fact that an unexpected value is being used.
@discardableResult
public func unexpected<T>(
    _ value: T,
    _ message: String? = nil,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
    ) -> T {
    if let message = message {
        print("\(message), file: \(file), function: \(function), line: \(line)")
    } else {
        print("Unexpected execution at file: \(file), function: \(function), line: \(line)")
    }

    return value
}
