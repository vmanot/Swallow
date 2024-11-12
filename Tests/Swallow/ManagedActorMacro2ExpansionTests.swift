//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swallow
import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ManagedActor2MacroExpansionTests: XCTestCase {
    static let macroNameIdentifier = "ManagedActor2"
    static let internalMethodMacroNameIdentifier = "_ManagedActorMethod2"
    static let methodMacroNameIdentifier = "ManagedActorMethod2"
    static let extensionMacroNameIdentifier = "ManagedActorExtension2"
    
    func testExpansionWithDollarSignFunction() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroExpansionTests.macroNameIdentifier)
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
                @\(ManagedActor2MacroExpansionTests.internalMethodMacroNameIdentifier)
                func test$() {
                    print("Hello")
                }
                
                func regularFunc() {
                    print("Regular")
                }

                public lazy var _managedActorDispatch = _ManagedActorDispatch2(owner: self)
            }

            extension TestActor: _ManagedActorProtocol2 {
                public static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> {
                    []
                }
            }
            """,
            macros: [ManagedActor2MacroExpansionTests.macroNameIdentifier: ManagedActorMacro2.self]
        )
    }
    
    func testExpansionWithExtension() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroExpansionTests.macroNameIdentifier)
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
                @\(ManagedActor2MacroExpansionTests.internalMethodMacroNameIdentifier)
                func extensionFunc$() {
                    print("Extension")
                }
                
                func regularFunc() {
                    print("Regular")
                }
            }
            """,
            macros: [ManagedActor2MacroExpansionTests.macroNameIdentifier: ManagedActorMacro2.self]
        )
    }
    
    func testExpansionWithPreexistingManagedActorMethod() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroExpansionTests.macroNameIdentifier)
            class TestActor {
                @\(ManagedActor2MacroExpansionTests.methodMacroNameIdentifier)
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
                @\(ManagedActor2MacroExpansionTests.methodMacroNameIdentifier)
                func alreadyManaged$() {
                    print("Already managed")
                }
                @\(ManagedActor2MacroExpansionTests.internalMethodMacroNameIdentifier)
                
                func new$() {
                    print("New")
                }

                public lazy var _managedActorDispatch = _ManagedActorDispatch2(owner: self)
            }

            extension TestActor: _ManagedActorProtocol2 {
                public static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> {
                    []
                }
            }
            """,
            macros: [ManagedActor2MacroExpansionTests.macroNameIdentifier: ManagedActorMacro2.self]
        )
    }
    
    func testMethodMacroExpansion() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroExpansionTests.methodMacroNameIdentifier)
            func test$() {
                print("Hello World!")
            }
            
            @\(ManagedActor2MacroExpansionTests.methodMacroNameIdentifier)
            func asyncTest() async {
                print("Hello World!")
            }
            
            @\(ManagedActor2MacroExpansionTests.methodMacroNameIdentifier)
            func throwingTest() throws {
                print("Hello World!")
            }
            
            @\(ManagedActor2MacroExpansionTests.methodMacroNameIdentifier)
            func throwingAsyncTest() async throws {
                print("Hello World!")
            }
            """,
            expandedSource: """
            func test$() {
                return self._performOperation {
                    print("Hello World!")
                }
            }
            func asyncTest() async {
                return await self._performAsyncOperation {
                    print("Hello World!")
                }
            }
            func throwingTest() throws {
                return try self._performThrowingOperation {
                    print("Hello World!")
                }
            }
            func throwingAsyncTest() async throws {
                return try await self._performThrowingAsyncOperation {
                    print("Hello World!")
                }
            }
            """,
            macros: [ManagedActor2MacroExpansionTests.methodMacroNameIdentifier: ManagedActorMethodMacro2.self]
        )
    }
    
    func testAllMacrosExpansion() {
        assertMacroExpansion(
            """
            @\(ManagedActor2MacroExpansionTests.macroNameIdentifier)(.serializedExecution)
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

            @\(ManagedActor2MacroExpansionTests.extensionMacroNameIdentifier)
            extension TestActor {
                func baz$() {
                    print("what")
                }
            }
            """,
            expandedSource: """
            fileprivate final class TestActor {
                var x: Int = 0
                
                func foo$(
                    _ x: Int
                ) async throws -> Int {
                    return try await self._performThrowingAsyncOperation {
                            return 68 + x
                    }
                }
                
                func bar$(
                    _ int: Int
                ) async throws -> Int {
                    return try await self._performThrowingAsyncOperation {
                            self.baz$()

                            return try await self.foo$(-68) + int
                    }
                }
                
                func bart$(
                    _ int: Int
                ) async throws -> Int {
                    return try await self._performThrowingAsyncOperation {
                            self.baz$()

                            return try await self.foo$(-68) + int
                    }
                }

                public lazy var _managedActorDispatch = _ManagedActorDispatch2(owner: self)
            }
            extension TestActor {
                func baz$() {
                    return self._performOperation {
                            print("what")
                    }
                }
            }

            extension TestActor: _ManagedActorProtocol2 {
                public static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> {
                    [.serializedExecution]
                }
            }
            """,
            macros: [
                ManagedActor2MacroExpansionTests.macroNameIdentifier: ManagedActorMacro2.self,
                ManagedActor2MacroExpansionTests.extensionMacroNameIdentifier: ManagedActorMacro2.self,
                ManagedActor2MacroExpansionTests.methodMacroNameIdentifier: ManagedActorMethodMacro2.self,
                ManagedActor2MacroExpansionTests.internalMethodMacroNameIdentifier: ManagedActorMethodMacro2.self
            ]
        )
    }
}
