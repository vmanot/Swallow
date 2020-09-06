//
// Copyright (c) Vatsal Manot
//

import Swift

public func silent<T>(_ x: (@autoclosure @escaping () throws -> T)) -> (() -> T?) {
    return { try? x() }
}

public func silent<T>(_ x: (@autoclosure @escaping () throws -> T?)) -> (() -> T?) {
    return { (try? x()) ?? nil }
}

public func silent<T, U>(_ f: (@escaping (T) throws -> U)) -> ((T) -> U?) {
    return { try? f($0) }
}

public func silent<T, U>(_ f: (@escaping (T) throws -> U?)) -> ((T) -> U?) {
    return { (try? f($0)) ?? nil }
}

public func silence<T>(_ x: (@autoclosure @escaping () throws -> T)) -> T? {
    return silent(x)()
}

public func silence<T>(_ x: (@autoclosure @escaping () throws -> T?)) -> T? {
    return silent(x)()
}
