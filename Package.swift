// swift-tools-version:5.9

import CompilerPluginSupport
import PackageDescription

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
                "_SwallowSwiftOverlay",
                "SE0270_RangeSet",
                "Swallow",
                "SwallowMacrosClient",
                "Compute",
                "CoreModel",
                "Diagnostics",
                "FoundationX",
                "LoremIpsum",
                "POSIX",
                "_RuntimeKeyPath",
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
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
    ],
    targets: [
        .target(
            name: "_PythonString",
            dependencies: [],
            swiftSettings: []
        ),
        .target(
            name: "_SwallowMacrosRuntime",
            dependencies: [
                "_RuntimeC",
                "Swallow",
            ],
            path: "Macros/_SwallowMacrosRuntime",
            swiftSettings: []
        ),
        .target(
            name: "_SwallowSwiftOverlay",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ],
            path: "Sources/_SwallowSwiftOverlay",
            swiftSettings: []
        ),
        .target(
            name: "LoremIpsum",
            swiftSettings: []
        ),
        .target(
            name: "SE0270_RangeSet",
            swiftSettings: []
        ),
        .target(
            name: "Swallow",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                "_RuntimeC",
                "_SwallowSwiftOverlay",
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Compute",
            dependencies: [
                "Diagnostics",
                .product(name: "Collections", package: "swift-collections"),
                "Swallow"
            ],
            swiftSettings: []
        ),
        .target(
            name: "CoreModel",
            dependencies: [
                "Diagnostics",
                .product(name: "Collections", package: "swift-collections"),
                "Swallow"
            ],
            swiftSettings: []
        ),
        .target(
            name: "Diagnostics",
            dependencies: [
                "Swallow",
                "SwallowMacrosClient",
            ],
            swiftSettings: []
        ),
        .target(
            name: "FoundationX",
            dependencies: [
                "Diagnostics",
                "Swallow",
            ],
            swiftSettings: []
        ),
        .target(
            name: "POSIX",
            dependencies: [
                "Swallow",
            ],
            swiftSettings: []
        ),
        .target(
            name: "_RuntimeC",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ]
        ),
        .target(
            name: "_RuntimeKeyPath",
            dependencies: [
                "_SwallowMacrosRuntime",
                "Swallow"
            ],
            swiftSettings: [.unsafeFlags(["-parse-stdlib"])]
        ),
        .target(
            name: "Runtime",
            dependencies: [
                "_RuntimeC",
                "_RuntimeKeyPath",
                "_SwallowMacrosRuntime",
                "Compute",
                "FoundationX",
                "Swallow"
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .macro(
            name: "SwallowMacros",
            dependencies: [
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SwiftSyntaxUtilities",
            ],
            path: "Macros/SwallowMacros"
        ),
        .target(
            name: "SwallowMacrosClient",
            dependencies: [
                "_SwallowMacrosRuntime",
                "SwallowMacros",
                "Swallow"
            ],
            path: "Macros/SwallowMacrosClient",
            swiftSettings: []
        ),
        .target(
            name: "MacroBuilder",
            dependencies: [
                "MacroBuilderCore",
                "Swallow",
                "SwiftSyntaxUtilities",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "Macros/MacroBuilder"
        ),
        .target(
            name: "MacroBuilderCore",
            dependencies: [
                "SwallowMacros",
                "Swallow",
            ],
            path: "Macros/MacroBuilderCore"
        ),
        .target(
            name: "SwiftSyntaxUtilities",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "Swallow",
            ],
            path: "Macros/SwiftSyntaxUtilities"
        ),
        .testTarget(
            name: "SwallowTests",
            dependencies: [
                "_RuntimeC",
                "Runtime",
                "Swallow",
                "SwallowMacros",
                "SwallowMacrosClient",
                "SwiftSyntaxUtilities",
            ],
            path: "Tests/Swallow"
        ),
    ]
)
