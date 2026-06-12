//
// Copyright (c) Vatsal Manot
//
//
// NSTextAttachment attachment-character compatibility reference
//
// The table records the attachment-character declaration imported by each
// SDK/Swift importer configuration and the compatibility declaration supplied
// by this file so both public spellings remain available to clients.
//
// Table fields:
//   property
//     The `NSTextAttachment.character` type property.
//   global
//     The `NSAttachmentCharacter` global constant.
//   SDK Declaration
//     Declaration imported by the SDK/Swift importer before this file contributes.
//   Compatibility
//     Declaration supplied by this file for the active importer configuration.
//   PASS
//     Debug build passed.
//   No SDK
//     Platform SDK component was not installed in the tested Xcode bundle.
//
// +------------------------+---------+--------------------+----------+----------+--------+
// | Xcode                  | Swift   | Platform           | SDK      | Compat   | Result |
// +------------------------+---------+--------------------+----------+----------+--------+
// | 16.4 (16F6)            | 6.1.2   | macOS              | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | Mac Catalyst       | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | iOS                | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | iOS Simulator      | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | tvOS               | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | tvOS Simulator     | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | watchOS            | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | watchOS Simulator  | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | visionOS           | property | global   | PASS   |
// | 16.4 (16F6)            | 6.1.2   | visionOS Simulator | property | global   | PASS   |
// | 26.1 (17B55)           | 6.2.1   | macOS              | property | global   | PASS   |
// | 26.1 (17B55)           | 6.2.1   | Mac Catalyst       | property | global   | PASS   |
// | 26.1 (17B55)           | 6.2.1   | iOS                | --       | --       | No SDK |
// | 26.1 (17B55)           | 6.2.1   | iOS Simulator      | --       | --       | No SDK |
// | 26.1 (17B55)           | 6.2.1   | tvOS               | --       | --       | No SDK |
// | 26.1 (17B55)           | 6.2.1   | tvOS Simulator     | --       | --       | No SDK |
// | 26.1 (17B55)           | 6.2.1   | watchOS            | --       | --       | No SDK |
// | 26.1 (17B55)           | 6.2.1   | watchOS Simulator  | --       | --       | No SDK |
// | 26.1 (17B55)           | 6.2.1   | visionOS           | --       | --       | No SDK |
// | 26.1 (17B55)           | 6.2.1   | visionOS Simulator | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | macOS              | property | global   | PASS   |
// | 26.2 (17C52)           | 6.2.3   | Mac Catalyst       | property | global   | PASS   |
// | 26.2 (17C52)           | 6.2.3   | iOS                | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | iOS Simulator      | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | tvOS               | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | tvOS Simulator     | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | watchOS            | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | watchOS Simulator  | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | visionOS           | --       | --       | No SDK |
// | 26.2 (17C52)           | 6.2.3   | visionOS Simulator | --       | --       | No SDK |
// | 26.4.1 (17E202)        | 6.3.1   | macOS              | global   | property | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | Mac Catalyst       | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | iOS                | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | iOS Simulator      | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | tvOS               | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | tvOS Simulator     | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | watchOS            | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | watchOS Simulator  | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | visionOS           | property | global   | PASS   |
// | 26.4.1 (17E202)        | 6.3.1   | visionOS Simulator | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | macOS              | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | Mac Catalyst       | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | iOS                | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | iOS Simulator      | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | tvOS               | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | tvOS Simulator     | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | watchOS            | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | watchOS Simulator  | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | visionOS           | property | global   | PASS   |
// | 26.5 (17F42)           | 6.3.2   | visionOS Simulator | property | global   | PASS   |
// +------------------------+---------+--------------------+----------+----------+--------+
//
// Compatibility notes:
// - The compatibility declaration is always defined in terms of the declaration
//   imported by the active SDK/importer configuration; this file does not
//   synthesize the raw attachment Unicode scalar directly.
// - In the toolchains covered above, Xcode 26.4.1 (Swift 6.3.1) on native macOS
//   is the only configuration where the SDK imports `NSAttachmentCharacter`
//   without `NSTextAttachment.character`.
// - Xcode 26.4.1 Mac Catalyst and UIKit-family platforms import
//   `NSTextAttachment.character`; this file supplies `NSAttachmentCharacter`
//   there to keep both public spellings available.
// - Xcode 26.5 (Swift 6.3.2) restores `NSTextAttachment.character` for native
//   macOS, and Xcode 16.4 through Swift 6.2.x already expose it.
// - canImport(UIKit) covers the UIKit-family platforms in the table, including
//   watchOS.
// - The compatibility probe references both declarations so every compiled
//   configuration validates the complete public compatibility surface.
// - PASS records Debug configuration coverage.
//
// Coverage gaps:
// - Xcode 26.1/26.2 iOS, tvOS, watchOS, and visionOS device/simulator rows are
//   recorded as No SDK because those platform components were not installed in
//   the referenced Xcode bundles.
// - The 26.4-family coverage is represented by Xcode 26.4.1 (17E202); no
//   separate Xcode 26.4.0 entry is included.
//

#if os(macOS)
import AppKit
#endif
import QuartzCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if os(macOS) || canImport(UIKit)
#if compiler(>=6.3.1) && !compiler(>=6.3.2)
#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit

/// Fix for Xcode 26.4.1 where the Swift importer exposes
/// `NSAttachmentCharacter` but not `NSTextAttachment.character`.
extension NSTextAttachment {
    static var character: Int {
        NSAttachmentCharacter
    }
}
#else
/// Compatibility alias for SDKs where `NSAttachmentCharacter` is obsoleted in
/// favor of `NSTextAttachment.character`.
public var NSAttachmentCharacter: Int {
    NSTextAttachment.character
}
#endif
#else
/// Compatibility alias for SDKs where `NSAttachmentCharacter` is obsoleted in
/// favor of `NSTextAttachment.character`.
public var NSAttachmentCharacter: Int {
    NSTextAttachment.character
}
#endif

// Forces both public spellings to type-check in every compiled configuration.
private var _NSTextAttachmentCharacterCompatibilityProbe: (Int, Int) {
    (NSTextAttachment.character, NSAttachmentCharacter)
}
#endif
