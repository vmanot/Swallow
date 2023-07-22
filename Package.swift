// swift-tools-version:5.7

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
                "_LoremIpsum",
                "Compute",
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
        .package(url: "https://github.com/apple/swift-collections", branch: "main"),
    ],
    targets: [
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
            swiftSettings: []
        ),
        .target(
            name: "Diagnostics",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: []
        ),
        .target(
            name: "FoundationX",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: []
        ),
        .target(
            name: "POSIX",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: []
        ),
        .target(
            name: "PythonString",
            dependencies: [
                "Swallow"
            ],
            swiftSettings: []
        ),
        .target(
            name: "Runtime",
            dependencies: [
                "Compute",
                "FoundationX",
                "Swallow"
            ],
            swiftSettings: []
        ),
        .target(
            name: "SE0270_RangeSet"
        ),
        .target(
            name: "Swallow",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            swiftSettings: []
        ),
        .testTarget(
            name: "SwallowTests",
            dependencies: [
                "Swallow"
            ]
        ),
    ]
)
