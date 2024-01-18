// swift-tools-version:5.9

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
                "_LoremIpsum",
                "Compute",
                "CoreModel",
                "Diagnostics",
                "FoundationX",
                "POSIX",
                "PythonString",
                "Runtime",
                "SE0270_RangeSet",
                "Swallow"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", branch: "release/1.1"),
    ],
    targets: [
        .target(
            name: "_ExpansionsRuntime",
            dependencies: [
                "Diagnostics",
                "Runtime",
                "Swallow",
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "_LoremIpsum"
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
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
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
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
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
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
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
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
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
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
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
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
                    "-enable-library-evolution"
                ])
            ]
        ),
        .target(
            name: "Runtime",
            dependencies: [
                "Compute",
                "FoundationX",
                "Swallow"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
                    "-enable-library-evolution"
                ])
            ]
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
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
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
