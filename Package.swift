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
                "_ExpansionsRuntime",
                "SE0270_RangeSet",
                "Swallow",
                "Expansions",
                "MacroBuilder",
                "SwiftSyntaxUtilities",
                "Compute",
                "CoreModel",
                "Diagnostics",
                "FoundationX",
                "LoremIpsum",
                "POSIX",
                "PythonString",
                "Runtime",
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
    ],
    targets: [
        .target(
            name: "_ExpansionsRuntime",
            dependencies: [
                "Diagnostics",
                "Swallow",
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .macro(
            name: "ExpansionsMacros",
            dependencies: [
                "Swallow",
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SwiftSyntaxUtilities",
            ],
            path: "Sources/ExpansionsMacros"
        ),
        .macro(
            name: "MacroBuilderCompilerPlugin",
            dependencies: [
                "MacroBuilderCore",
                "Swallow"
            ],
            path: "Sources/MacroBuilderCompilerPlugin"
        ),
        .target(
            name: "LoremIpsum"
        ),
        .target(
            name: "SE0270_RangeSet"
        ),
        .target(
            name: "Swallow",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "Expansions",
            dependencies: [
                "_ExpansionsRuntime",
                "ExpansionsMacros",
                "Swallow"
            ],
            path: "Sources/Expansions"
        ),
        .target(
            name: "MacroBuilder",
            dependencies: [
                "Expansions",
                "MacroBuilderCore",
                "Swallow",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "Sources/MacroBuilder"
        ),
        .target(
            name: "MacroBuilderCore",
            dependencies: [
                "ExpansionsMacros",
                "Swallow",
            ],
            path: "Sources/MacroBuilderCore"
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
            path: "Sources/SwiftSyntaxUtilities"
        ),
        .target(
            name: "Compute",
            dependencies: [
                "Diagnostics",
                .product(name: "Collections", package: "swift-collections"),
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
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
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "Diagnostics",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "FoundationX",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "POSIX",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "PythonString",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "Runtime",
            dependencies: [
                "_ExpansionsRuntime",
                "Compute",
                "FoundationX",
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution"
                ])
            ]
        ),
        .testTarget(
            name: "SwallowTests",
            dependencies: [
                "Runtime",
                "Swallow"
            ]
        ),
    ]
)
