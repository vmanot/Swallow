//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol UnsafeBufferPointerInitiable {
    init<T>(_: UnsafeBufferPointer<T>)
    init<T>(_: UnsafeMutableBufferPointer<T>)
}
