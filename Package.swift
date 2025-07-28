// swift-tools-version:6.1

import CompilerPluginSupport
import Foundation
import PackageDescription

var dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
]
#if compiler(>=6.1)
dependencies += [.package(url: "https://github.com/swift-precompiled/swift-syntax", branch: "release/6.1")]
#else
dependencies += [.package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.1")]
#endif

let package = Package(
    name: "Swallow",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Swallow",
            targets: [
                "_PythonString",
                "_RuntimeC",
                "_RuntimeKeyPath",
                "_SwallowSwiftOverlay",
                "_SwiftRuntimeExports",
                "SE0270_RangeSet",
                "Swallow",
                "Compute",
                "CoreModel",
                "Diagnostics",
                "FoundationX",
                "LoremIpsum",
                "POSIX",
                "Runtime",
            ]
        ),
        .library(
            name: "SwallowMacrosClient",
            targets: [
                "SwallowMacrosClient"
            ]
        ),
        .library(
            name: "MacroBuilder",
            targets: [
                "MacroBuilder"
            ]
        )
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "_SwiftRuntimeExports",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"]),
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "_PythonString",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "_SwallowSwiftOverlay",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ],
            path: "Sources/_SwallowSwiftOverlay",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "LoremIpsum",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "SE0270_RangeSet",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "Swallow",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                "_RuntimeC",
                "_SwallowSwiftOverlay",
                "_SwiftRuntimeExports",
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "Compute",
            dependencies: [
                "Diagnostics",
                .product(name: "Collections", package: "swift-collections"),
                "Swallow"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "CoreModel",
            dependencies: [
                "Diagnostics",
                .product(name: "Collections", package: "swift-collections"),
                "Swallow"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "Diagnostics",
            dependencies: [
                "Swallow",
                "SwallowMacrosClient",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "FoundationX",
            dependencies: [
                "Diagnostics",
                "Swallow",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "POSIX",
            dependencies: [
                "Swallow",
                "SwallowMacrosClient",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "_RuntimeC",
            exclude: [],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "_RuntimeKeyPath",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-stdlib"]),
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "Runtime",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics"),
                "_RuntimeC",
                "_RuntimeKeyPath",
                "Compute",
                "FoundationX",
                "Swallow"
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
                .swiftLanguageMode(.v5)
            ]
        ),
        .macro(
            name: "SwallowMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .target(name: "SwiftSyntaxUtilities", condition: .when(platforms: [.macOS])),
            ],
            path: "Macros/SwallowMacros",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "SwallowMacrosClient",
            dependencies: [
                "SwallowMacros",
                "Swallow"
            ],
            path: "Macros/SwallowMacrosClient",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "MacroBuilder",
            dependencies: [
                "Swallow",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftSyntax", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .target(name: "SwiftSyntaxUtilities", condition: .when(platforms: [.macOS])),
            ],
            path: "Macros/MacroBuilder",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "SwiftSyntaxUtilities",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftSyntax", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                "Swallow",
            ],
            path: "Macros/SwiftSyntaxUtilities",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "SwallowTests",
            dependencies: [
                "_RuntimeC",
                "Runtime",
                "Swallow",
                "SwallowMacrosClient",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax", condition: .when(platforms: [.macOS])),
                .target(name: "SwiftSyntaxUtilities", condition: .when(platforms: [.macOS])),
            ],
            path: "Tests/Swallow",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

// package-manifest-patch:start
#if arch(arm64) && os(macOS)
if ProcessInfo.processInfo.environment["FUCK_SWIFT_SYNTAX"] != nil {
    patchSwiftSyntaxDependency(in: package)
}
#endif

private func patchSwiftSyntaxDependency(in package: Package) {
    if let swiftSyntaxIndex = package.dependencies.firstIndex(where: { (dependency: Package.Dependency) in
        guard case .sourceControl(_, let location, _) = dependency.kind else {
            return false
        }
        
        return location.contains("apple/swift-syntax.git") || location.contains("swiftlang/swift-syntax.git")
    }) {
        package.dependencies[swiftSyntaxIndex] = Package.Dependency.package(
            url: "https://github.com/swift-precompiled/swift-syntax",
            from: "600.0.0"
        )
    }
}
// package-manifest-patch:end
