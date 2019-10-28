//
// Copyright (c) Vatsal Manot
//

import Swift

public func debugLog(_ x: Any, function: StaticString = #function) {
    print("\(String(describing: x)), \(function)")
}
