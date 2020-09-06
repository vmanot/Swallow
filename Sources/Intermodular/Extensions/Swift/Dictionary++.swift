//
// Copyright (c) Vatsal Manot
//

import Swift

extension Dictionary {
    public func mapKeysAndValues<T: Hashable, U>(_ transformKey: (Key) throws -> T, _ transformValue: (Value) throws -> U) rethrows -> [T: U] {
        var result = Dictionary<T, U>(minimumCapacity: count)

        for (key, value) in self {
            result[try transformKey(key)] = try transformValue(value)
        }

        return result
    }
}
