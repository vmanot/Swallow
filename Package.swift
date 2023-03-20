// swift-tools-version:5.5

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
                "Swallow"
            ]
        )
    ],
    targets: [
        .target(
            name: "Swallow",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SwallowTests",
            dependencies: ["Swallow"],
            path: "Tests"
        )
    ]
)
