//
// Copyright (c) Vatsal Manot
//

import SwallowMacrosClient
import XCTest
import Distributed

/*@GenerateTypeEraser
public protocol TypeErasableProtocol1 {
    func boo() -> Int
    func bar() throws -> Int
    func baz() async -> Int
    func foo() async throws -> Int
}

struct Baz: TypeErasableProtocol1 {
    func boo() -> Int {
        return 69
    }
    
    func bar() throws -> Int {
        return 69
    }
    
    func baz() async -> Int {
        return 69
    }
    
    func foo() async throws -> Int {
        return 69
    }
}

func foo(x: TypeErasableProtocol1) {
    x.boo()
}
*/
