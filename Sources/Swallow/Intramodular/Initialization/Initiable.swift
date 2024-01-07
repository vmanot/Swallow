//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _ThrowingInitiable {
    init() throws
}

public protocol Initiable {
    init()
}

public protocol AllCaseInitiable {
    static var all: Self { get }
}
