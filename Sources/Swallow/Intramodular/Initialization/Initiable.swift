//
// Copyright (c) Vatsal Manot
//

import Swift

@_alwaysEmitConformanceMetadata
public protocol _ThrowingInitiable {
    init() throws
}

@_alwaysEmitConformanceMetadata
public protocol Initiable: _ThrowingInitiable {
    init()
}

@_alwaysEmitConformanceMetadata
public protocol AllCaseInitiable {
    static var all: Self { get }
}
