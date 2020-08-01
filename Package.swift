// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Swallow",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Swallow", targets: ["Swallow"])
    ],
    targets: [
        .target(name: "Swallow", dependencies: [], path: "Sources")
    ]
)
