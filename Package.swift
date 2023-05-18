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
                "Compute",
                "Diagnostics",
                "FoundationX",
                "POSIX",
                "Runtime",
                "RuntimeShims",
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
            name: "SE0270_RangeSet"
        ),
        .target(
            name: "Compute",
            dependencies: [
                "Diagnostics",
                .product(name: "Collections", package: "swift-collections"),
                "Swallow"
            ]
        ),
        .target(
            name: "Diagnostics",
            dependencies: [
                "Swallow"
            ]
        ),
        .target(
            name: "POSIX",
            dependencies: [
                "Swallow"
            ]
        ),
        .target(
            name: "FoundationX",
            dependencies: [
                "Swallow"
            ]
        ),
        .target(
            name: "Runtime",
            dependencies: [
                "FoundationX",
                "RuntimeShims",
                "Swallow"
            ]
        ),
        .target(
            name: "RuntimeShims"
        ),
        .target(
            name: "Swallow",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "SwallowTests",
            dependencies: [
                "Swallow"
            ]
        ),
    ]
)
