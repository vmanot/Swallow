// swift-tools-version:5.10

import CompilerPluginSupport
import Foundation
import PackageDescription

var package = Package(
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
            name: "_SwallowSwiftOverlay",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections"),
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
                .product(name: "OrderedCollections", package: "swift-collections"),
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
                "Swallow"
            ],
            swiftSettings: [.unsafeFlags(["-parse-stdlib"])]
        ),
        .target(
            name: "Runtime",
            dependencies: [
                "_RuntimeC",
                "_RuntimeKeyPath",
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
                .target(name: "SwiftSyntaxUtilities", condition: .when(platforms: [.macOS])),
            ],
            path: "Macros/SwallowMacros"
        ),
        .target(
            name: "SwallowMacrosClient",
            dependencies: [
                "SwallowMacros",
                "Swallow"
            ],
            path: "Macros/SwallowMacrosClient",
            swiftSettings: []
        ),
        .target(
            name: "MacroBuilder",
            dependencies: [
                "Swallow",
                .target(name: "SwiftSyntaxUtilities", condition: .when(platforms: [.macOS])),
            ],
            path: "Macros/MacroBuilder"
        ),
        .target(
            name: "SwiftSyntaxUtilities",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
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
                .target(name: "SwiftSyntaxUtilities", condition: .when(platforms: [.macOS])),
            ],
            path: "Tests/Swallow"
        ),
    ],
    swiftLanguageVersions: [.v5]
)

// package-manifest-patch:start
#if arch(arm64) && os(macOS) 
if ProcessInfo.processInfo.environment["FUCK_SWIFT_SYNTAX"] != nil {
    patchSwiftSyntaxDependency(in: &package)
}
#endif

private func patchSwiftSyntaxDependency(in package: inout Package) {
    if let swiftSyntaxIndex = package.dependencies.firstIndex(where: { (dependency: Package.Dependency) in
        guard case .sourceControl(_, let location, _) = dependency.kind else {
            return false
        }
        
        return location.contains("apple/swift-syntax.git")
    }) {
        package.dependencies[swiftSyntaxIndex] = Package.Dependency.package(
            url: "https://github.com/sjavora/swift-syntax-xcframeworks.git",
            from: "510.0.1"
        )
    }
    
    for index in 0..<package.targets.count {
        var target: Target = package.targets[index]
        var patched: Bool = false
        
        target.dependencies = target.dependencies.compactMap { (dependency: Target.Dependency) -> Target.Dependency? in
            switch dependency {
                case .productItem(let name, let package, let moduleAliases, let condition):
                    let targets: Set<String> = ["SwiftSyntax", "SwiftSyntaxMacros", "SwiftCompilerPlugin", "SwiftParserDiagnostics"]
                    
                    if package == "swift-syntax", targets.contains(name) {
                        if patched {
                            return nil
                        }
                        
                        patched = true
                        
                        return .productItem(
                            name: "SwiftSyntaxWrapper",
                            package: "swift-syntax-xcframeworks",
                            moduleAliases: moduleAliases,
                            condition: .when(platforms: [.macOS])
                        )
                    }
                    
                default:
                    break
            }
            
            return dependency
        }
        
        package.targets[index] = target
    }
}
// package-manifest-patch:end
