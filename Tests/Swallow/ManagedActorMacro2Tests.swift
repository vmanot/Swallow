//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swallow
import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ManagedActor2MacroTests: XCTestCase {
    static let macroNameIdentifier = "ManagedActor2"
    static let methodMacroNameIdentifier = "_ManagedActorMethod2"
    
    func testExpansionWithDollarSignFunction() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroTests.macroNameIdentifier)
            class TestActor {
                func test$() {
                    print("Hello")
                }
                
                func regularFunc() {
                    print("Regular")
                }
            }
            """,
            expandedSource: """
            class TestActor {
                @_ManagedActorMethod2
                func test$() {
                    print("Hello")
                }
                
                func regularFunc() {
                    print("Regular")
                }
            }
            """,
            macros: [ManagedActor2MacroTests.macroNameIdentifier: ManagedActorMacro2.self]
        )
    }
    
    func testExpansionWithExtension() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroTests.macroNameIdentifier)
            extension TestActor {
                func extensionFunc$() {
                    print("Extension")
                }
                
                func regularFunc() {
                    print("Regular")
                }
            }
            """,
            expandedSource: """
            extension TestActor {
                @_ManagedActorMethod2
                func extensionFunc$() {
                    print("Extension")
                }
                
                func regularFunc() {
                    print("Regular")
                }
            }
            """,
            macros: [ManagedActor2MacroTests.macroNameIdentifier: ManagedActorMacro2.self]
        )
    }
    
    func testExpansionWithPreexistingManagedActorMethod() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroTests.macroNameIdentifier)
            class TestActor {
                @ManagedActorMethod2
                func alreadyManaged$() {
                    print("Already managed")
                }
                
                func new$() {
                    print("New")
                }
            }
            """,
            expandedSource: """
            class TestActor {
                @ManagedActorMethod2
                func alreadyManaged$() {
                    print("Already managed")
                }
                @_ManagedActorMethod2
                
                func new$() {
                    print("New")
                }
            }
            """,
            macros: [ManagedActor2MacroTests.macroNameIdentifier: ManagedActorMacro2.self]
        )
    }
    
    func testMethodMacroExpansion() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroTests.methodMacroNameIdentifier)
            func test$() {
                print("Original")
            }
            
            @\(ManagedActor2MacroTests.methodMacroNameIdentifier)
            func test() {
                print("Original")
            }
            """,
            expandedSource: """
            func test$() {
                {
                    print("Original")
                }
            }
            func test() {
                {
                    print("Original")
                }
            }
            """,
            macros: [ManagedActor2MacroTests.methodMacroNameIdentifier: ManagedActorMethodMacro2.self]
        )
    }
}
