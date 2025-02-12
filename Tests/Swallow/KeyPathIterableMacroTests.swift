//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwallowMacrosClient
import SwiftUI
import XCTest

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
final class KeyPathIterableMacroTests: XCTestCase {
    func testKeyPathIterableMacro() {
        let keyPaths: Set<PartialKeyPath> = Set(KeyPathIterableMacroFoo.allKeyPaths)
        
        XCTAssertEqual(keyPaths, [\KeyPathIterableMacroFoo.id, \KeyPathIterableMacroFoo.name, \KeyPathIterableMacroFoo.favorite])
    }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@Observable
@KeyPathIterable
public final class KeyPathIterableMacroFoo {
    var id = UUID()
    var name: String
    var favorite: Bool
    
    init(id: UUID = UUID(), name: String, favorite: Bool) {
        self.id = id
        self.name = name
        self.favorite = favorite
    }
    
    func toggleFavorite() {
        withAnimation {
            favorite.toggle()
        }
    }
    
    static func == (lhs: KeyPathIterableMacroFoo, rhs: KeyPathIterableMacroFoo) -> Bool {
        lhs.id == rhs.id
    }
}

