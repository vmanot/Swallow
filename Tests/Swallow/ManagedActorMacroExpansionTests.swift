//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swallow
import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ManagedActorMacroExpansionTests: XCTestCase {
    static let macroNameIdentifier = "ManagedActor"
    static let methodMacroNameIdentifier = "_ManagedActorMethod"
    
    func testMacro() {
        assertMacroExpansion(
            """
            @\(ManagedActorMacroExpansionTests.macroNameIdentifier)(.serializedExecution)
            class TestActor {
                func test$() {
                    print("Hello")
                }
            
                func test2$() {
                    print("Hello")
                }
                
                func regularFunc() {
                    print("Regular")
                }
            }
            """,
            expandedSource: """
            class TestActor {
                @_disfavoredOverload @_ManagedActorMethod
                func test$() {
                    print("Hello")
                }
                @_disfavoredOverload @_ManagedActorMethod

                func test2$() {
                    print("Hello")
                }
                
                func regularFunc() {
                    print("Regular")
                }

                public lazy var _managedActorDispatch = _ManagedActorDispatch(owner: self)
            }

            struct _ManagedActorMethodTrampolineList_TestActor : _ManagedActorMethodTrampolineList {
                 typealias ManagedActorType = TestActor

                 let test = TestActor._ManagedActorMethod_test$()
                 let test2 = TestActor._ManagedActorMethod_test2$()

                public init() {

                }
            }

            extension TestActor: _ManagedActorProtocol {
                public typealias _ManagedActorMethodTrampolineListType = _ManagedActorMethodTrampolineList_TestActor

                public static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> {
                    [.serializedExecution]
                }

                public subscript <T: _ManagedActorMethodTrampolineProtocol>(
                    dynamicMember keyPath: KeyPath<_ManagedActorMethodTrampolineListType, T>
                ) -> T {
                    let result = _ManagedActorMethodTrampolineListType() [keyPath: keyPath]

                    result._caller = self

                    return result
                }
            }
            """,
            macros: [ManagedActorMacroExpansionTests.macroNameIdentifier: ManagedActorMacro.self]
        )
    }
    
    func testMacroForExtension() {
        assertMacroExpansion(
            """
            @\(ManagedActorMacroExpansionTests.macroNameIdentifier)
            extension TestActor {
                func dollarFunc$() {
                    print("Extension")
                }
                
                func regularFunc() {
                    print("Regular")
                }
            }
            """,
            expandedSource: """
            extension TestActor {
                @_disfavoredOverload @_ManagedActorMethod
                func dollarFunc$() {
                    print("Extension")
                }
                
                func regularFunc() {
                    print("Regular")
                }

                public final class _ManagedActorMethod_dollarFunc$: _PartialManagedActorMethodTrampoline<TestActor>, _ManagedActorMethodTrampolineProtocol {
                    public typealias OwnerType = _ManagedActorSelfType

                    public static var name: _ManagedActorMethodName {
                        _ManagedActorMethodName(rawValue: "_ManagedActorMethod_dollarFunc$")
                    }

                    public override init() {
                        super.init()
                    }

                     public
                        func callAsFunction()  {
                        caller._performInnerBodyOfMethod(\\.dollarFunc) {
                                self.caller.dollarFunc$()
                            }
                    }
                }

                 var dollarFunc: TestActor._ManagedActorMethod_dollarFunc$ {
                    let result = TestActor._ManagedActorMethod_dollarFunc$()

                    result.caller = self

                    return result
                }

                public final class _ManagedActorMethod_regularFunc: _PartialManagedActorMethodTrampoline<TestActor>, _ManagedActorMethodTrampolineProtocol {
                    public typealias OwnerType = _ManagedActorSelfType

                    public static var name: _ManagedActorMethodName {
                        _ManagedActorMethodName(rawValue: "_ManagedActorMethod_regularFunc")
                    }

                    public override init() {
                        super.init()
                    }

                     public

                        func callAsFunction()  {
                        caller._performInnerBodyOfMethod(\\.regularFunc) {
                                self.caller.regularFunc()
                            }
                    }
                }

                 var regularFunc: TestActor._ManagedActorMethod_regularFunc {
                    let result = TestActor._ManagedActorMethod_regularFunc()

                    result.caller = self

                    return result
                }
            }
            """,
            macros: [ManagedActorMacroExpansionTests.macroNameIdentifier: ManagedActorMacro.self]
        )
    }
    
    // @_ManagedActorMethod expansion does not seem to be working in a test.
    // Getting a bunch of parsing errors, and the test never completes.
    // It does work when I right click on the macro when it is used in the code and do Expand Macro.
    func needsFix_testManagedActorMethodMacro() {
        assertMacroExpansion(
            """
            @_ManagedActorMethod
            func alreadyManaged$() {
                print("Already managed")
            }
            """,
            expandedSource: """
            """,
            macros: [ManagedActorMacroExpansionTests.methodMacroNameIdentifier: ManagedActorMethodMacro.self]
        )
    }
}
