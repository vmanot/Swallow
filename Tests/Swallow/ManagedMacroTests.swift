//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swallow
import SwallowMacrosClient
import XCTest

final class ManagedMacroTests: XCTestCase {
    func testHashableExistentialInit() async throws {
       try await Barrz().foo(1)
    }
}

@ManagedActor
@dynamicMemberLookup
public final class Barrz {
    var x: Int = 0
    
     func foo(_ int: Int) async throws {
        try await bart(0)
    }
     
    func bart(_ int: Int) async throws {
        print("w")
    }
}
/*extension Barrz {
    @_dynamicReplacement(for: bart)
    func _bart(_ int: Int) async throws {
        try await self.bart(1)
    }
}
*/
