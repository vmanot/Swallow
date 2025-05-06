//
//  File.swift
//  Swallow
//
//  Created by Yasir on 06/05/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwallowMacros
import XCTest

final class TransactionKeyMacroTests: XCTestCase {
    static let macroNameIdentifier = "TransactionKey"
    
    func testTransactionKeyMacro() throws {
            assertMacroExpansion(
                    """
                    extension Transaction {
                        @TransactionKey
                        static var customValue: Bool = false
                    }
                    """,
                    expandedSource: """
                    extension Transaction {
                        static var customValue: Bool {
                            get {
                              self[TransactionKey_customValue.self]
                            }
                            set {
                              self[TransactionKey_customValue.self] = newValue
                            }
                        }
                    
                        private struct TransactionKey_customValue: TransactionKey {
                            static let defaultValue: Bool  = false
                        }
                    }
                    """,
                    macros: [TransactionKeyMacroTests.macroNameIdentifier: TransactionKeyMacro.self]
            )
        }
}
