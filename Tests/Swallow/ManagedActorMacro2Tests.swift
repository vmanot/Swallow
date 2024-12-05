//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swallow
import SwallowMacrosClient
import XCTest

final class ManagedActorMacro2Tests: XCTestCase {
    func testHashableExistentialInit() async throws {
        let actor = TestActor()
        
        XCTAssert(type(of: actor)._managedActorInitializationOptions == [.serializedExecution])
        
        let fooResult = try await actor.foo$(1)
        let barResult = try await actor.bar$(42)
        
        XCTAssert(fooResult == 69)
        XCTAssert(barResult == 42)
    }
}

@ManagedActor2(.serializedExecution)
fileprivate final class TestActor {
    var x: Int = 0
    
    func foo$(
        _ x: Int
    ) async throws -> Int {
        return 68 + x
    }
    
    func bar$(
        _ int: Int
    ) async throws -> Int {
        self.baz$()
        
        return try await self.foo$(-68) + int
    }
    
    func bart$(
        _ int: Int
    ) async throws -> Int {
        self.baz$()
        
        return try await self.foo$(-68) + int
    }
}

@ManagedActorExtension2
extension TestActor {
    func baz$() {
        print("what")
    }
}
