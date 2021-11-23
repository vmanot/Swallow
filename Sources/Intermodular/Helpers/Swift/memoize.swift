//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

private var data: [String: [Int: Any]] = [:]

public func memoize<T: Hashable, U>(
    uniquingWith value: T, file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    column: Int = #column,
    _ expression: (() -> U)
) -> U {
    let key = file.description + function.description + line.description + column.description
    
    data[key] ??= [:]
    
    if let result = data[key]![value.hashValue] {
        return result as! U
    }
        
    else {
        let result = expression()
        
        data[key]![value.hashValue] = result
        
        return result
    }
}

public func memoize<T: Hashable, U>(
    uniquingWith value: T,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    column: Int = #column,
    _ expression: @autoclosure () -> U
) -> U {
    return memoize(uniquingWith: value, file: file, function: function, line: line, column: column) {
        expression()
    }
}
