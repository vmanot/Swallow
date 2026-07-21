//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

#module(uniqueIdentifier: "com.vmanot.SwallowTests") {

}

@RuntimeDiscoverable
private struct RuntimeDiscoveryCompileFixture {

}

final class RuntimeDiscoveryMacroTests: XCTestCase {
    func testAttachedMacroUsesItsDeclaredSuffixedPeerName() {
        assertMacroExpansion(
            """
            @RuntimeDiscoverable
            struct Widget {
            }
            """,
            expandedSource: """
            struct Widget {
            }

            @objc public class Widget_RuntimeTypeDiscovery: Swallow._RuntimeTypeDiscovery {
                override public class var type: Any.Type {
                    Widget.self
                }

                override public init() {

                }
            }
            """,
            macros: ["RuntimeDiscoverable": RuntimeDiscoverableMacro.self]
        )
    }

    func testModuleMacroUsesItsDeclaredDiscoveryPeerName() {
        assertMacroExpansion(
            """
            #module(uniqueIdentifier: "com.example.module") {
            }
            """,
            expandedSource: """
            public final class _module: _StaticSwift.Module {
                public static var uniqueIdentifier: StaticString? {
                    get {
                        "com.example.module"
                    }
                }
            }
            @objc public class _module_RuntimeTypeDiscovery: Swallow._RuntimeTypeDiscovery {
                override public class var type: Any.Type {
                    _module.self
                }

                override public init() {

                }
            }
            """,
            macros: ["module": ModuleMacro.self]
        )
    }
}
