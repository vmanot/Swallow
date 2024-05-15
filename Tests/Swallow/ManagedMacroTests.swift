//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swallow
import SwallowMacrosClient
import XCTest

final class ManagedActorMacroTests: XCTestCase {
    func testHashableExistentialInit() async throws {
        let actor = Barrz()
        
        XCTAssert(type(of: actor)._managedActorInitializationOptions == [.serializedExecution])
        
        let result = try await actor.foo(1)
        
        XCTAssert(result == 69)
    }
}

@ManagedActor(.serializedExecution)
@dynamicMemberLookup
public final class Barrz {
    var x: Int = 0
    
    private func foo(
        _ int: Int
    ) async throws -> Int? {
        try await __managed_self.bart(0)
    }
    
    private func bart(
        _ int: Int
    ) async throws -> Int {
        69
    }
}
