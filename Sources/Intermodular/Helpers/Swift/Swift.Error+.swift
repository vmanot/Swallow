//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnyProtocol {
    public func `throw`(file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column, if predicate: ((Self) -> Bool)) throws {
        if predicate(self) {
            throw EmptyError(location: .init(file: file, function: function, line: line, column: column))
        }
    }
}

extension Boolean where Self: Error {
    public func orThrow(_ error: Error) throws {
        if !boolValue {
            throw error
        }
    }

    public func orThrow() throws {
        try orThrow(EmptyError()); TODO.here(.improve)
    }

    public func throwSelfIfFalse() throws {
        try orThrow(self)
    }
}

extension Collection {
    public func fatallyAssertIndexAsValidSubscriptArgument(_ index: Index, file: StaticString = #file, line: UInt = #line) {
        if (startIndex == endIndex) || (index < startIndex && index >= endIndex) {
            fatalError("Index out of range", file: file, line: line)
        }
    }

    public func fatallyAssertCollectionIsNotEmpty(file: StaticString = #file, line: UInt = #line) {
        if isEmpty {
            fatalError("Collection is empty", file: file, line: line)
        }
    }
}

extension Optional {
    @inlinable
    public func unwrapOrThrow(_ error: @autoclosure () throws -> Error) throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw try error()
        }
    }

    @inlinable
    public func orFatallyThrow(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            AnyError(description: message()).fatalThrow(file: file, line: line)
        }
    }

    @inlinable
    public func orFatallyThrowFunctionFailureError(_ function: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> Wrapped {
        return orFatallyThrow(String(describing: function) + " failure", file: file, line: line)
    }

    @inlinable
    public func orFatallyThrowUnimplementedError(_ function: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> Wrapped {
        return orFatallyThrow("\(function) unimplemented", file: file, line: line)
    }

    @inlinable
    public func forceUnwrap(file: StaticString = #file, line: UInt = #line) -> Wrapped {
        return orFatallyThrow("unexpectedly found nil while unwrapping an Optional value", file: file, line: line)
    }

    @inlinable
    public func unwrap(file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) throws -> Wrapped {
        guard let wrapped = self else {
            throw EmptyError(atFile: file, function: function, line: line, column: column)
        }

        return wrapped
    }
}
