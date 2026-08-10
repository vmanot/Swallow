// swift-tools-version:6.1

import CompilerPluginSupport
import PackageDescription

var dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
]
// SwiftSyntax macro binaries are coupled to the compiler's plugin protocol.
// Keep this package source-backed so changing Xcode versions cannot leave a
// stale precompiled plugin in the resolved graph.
dependencies += [.package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0")]

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
                "ErrorX",
                "FoundationX",
                "LoremIpsum",
                "POSIX",
                "Runtime",
            ]
        ),
        .library(
            name: "Diagnostics",
            targets: [
                "Diagnostics"
            ]
        ),
        .library(
            name: "DiagnosticsSwiftLog",
            targets: [
                "DiagnosticsSwiftLog"
            ]
        ),
        .library(
            name: "SwallowMacrosClient",
            targets: [
                "SwallowMacrosClient"
            ]
        ),
        .library(
            name: "ErrorX",
            targets: [
                "ErrorX"
            ]
        ),
        .library(
            name: "MacroBuilder",
            targets: [
                "MacroBuilder"
            ]
        ),
        .library(
            name: "SwiftSyntaxUtilities",
            targets: [
                "SwiftSyntaxUtilities"
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
            name: "ErrorX",
            dependencies: [
                "ErrorXMacros",
                "Swallow",
            ],
            path: "Sources/ErrorX",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .macro(
            name: "ErrorXMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SwiftSyntaxUtilities",
            ],
            path: "Macros/ErrorXMacros",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "Diagnostics",
            dependencies: [
                "ErrorX",
                "Swallow",
                "SwallowMacrosClient",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "DiagnosticsSwiftLog",
            dependencies: [
                "Diagnostics",
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
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
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SwiftSyntaxUtilities",
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
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                "SwiftSyntaxUtilities",
            ],
            path: "Macros/MacroBuilder",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "SwiftSyntaxUtilities",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                "Swallow",
            ],
            path: "Macros/SwiftSyntaxUtilities",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "SwiftSyntaxUtilitiesTests",
            dependencies: [
                "SwiftSyntaxUtilities",
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            path: "Tests/SwiftSyntaxUtilities",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SwallowTests",
            dependencies: [
                "_RuntimeC",
                "Runtime",
                "Swallow",
                "SwallowMacros",
                "SwallowMacrosClient",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "SwiftSyntaxUtilities",
            ],
            path: "Tests/Swallow",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "DiagnosticsTests",
            dependencies: [
                "Diagnostics",
                "Swallow",
                "SwiftSyntaxUtilities",
            ],
            path: "Tests/Diagnostics",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "DiagnosticsSwiftLogTests",
            dependencies: [
                "DiagnosticsSwiftLog",
                "Diagnostics",
                "SwiftSyntaxUtilities",
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "ErrorXTests",
            dependencies: [
                "ErrorX",
                "ErrorXMacros",
                "Swallow",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "SwiftSyntaxUtilities",
            ],
            path: "Tests/_ErrorXModule",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
    ],
    swiftLanguageModes: [.v5, .v6]
)
