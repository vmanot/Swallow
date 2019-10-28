//
// Copyright (c) Vatsal Manot
//

import Swift

@_transparent public func silent<T>(_ x: (@autoclosure @escaping () throws -> T)) -> (() -> T?) {
    return { try? x() }
}

@_transparent public func silent<T>(_ x: (@autoclosure @escaping () throws -> T?)) -> (() -> T?) {
    return { (try? x()) ?? nil }
}

@_transparent public func silent<T, U>(_ f: (@escaping (T) throws -> U)) -> ((T) -> U?) {
    return { try? f($0) }
}

@_transparent public func silent<T, U>(_ f: (@escaping (T) throws -> U?)) -> ((T) -> U?) {
    return { (try? f($0)) ?? nil }
}

@_transparent public func silence<T>(_ x: (@autoclosure @escaping () throws -> T)) -> T? {
    return silent(x)()
}

@_transparent public func silence<T>(_ x: (@autoclosure @escaping () throws -> T?)) -> T? {
    return silent(x)()
}
