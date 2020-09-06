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

extension Boolean  {
    public func orThrow(_ error: Error) throws {
        if !boolValue {
            throw error
        }
    }
    
    public func orThrow() throws {
        try orThrow(EmptyError()); TODO.here(.improve)
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
