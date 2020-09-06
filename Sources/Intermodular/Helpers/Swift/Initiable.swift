//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Initiable: AnyProtocol {
    init()
}

public protocol SelfInitiable: AnyProtocol {
    init(_: Self)
    init?(_: Self?)
}

// MARK: - Implementation -

extension SelfInitiable {
    public init(_ x: Self) {
        self = x
    }
    
    public init?(_ x: Self?) {
        guard let x = x else {
            return nil
        }
        
        self = x
    }
}

// MARK: - Auxiliary Extensions -

extension Initiable {
    public static func initThen(_ f: ((inout Self) throws -> ())) rethrows -> Self {
        return try Self.init().then(f)
    }
}
