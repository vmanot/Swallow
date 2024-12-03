//
// Copyright (c) Vatsal Manot
//

import Foundation
#if os(macOS)
import Security
#endif

#if DEBUG || os(macOS)
import Foundation
import MachO
import struct os.OSAllocatedUnfairLock

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ProcessInfo._AppDebugInfo {
    private static let _current: OSAllocatedUnfairLock<Self?> = .init(uncheckedState: nil)
    
    public static let current: Self = { () -> Self in
        _current.withLock {
            $0.unwrapOrInitializeInPlace {
                Self()
            }
        }
    }()
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ProcessInfo {
    public struct _AppDebugInfo: Codable, Equatable, Sendable {
        // MARK: Environment Variables
        public var SIMULATOR_HOST_HOME: String?
        public var DYLD_FRAMEWORK_PATH: [String]
        public var DYLD_LIBRARY_PATH: [String]
        public var DYLD_INSERT_LIBRARIES: String?
        public var __XPC_DYLD_FRAMEWORK_PATH: String?
        public var __XPC_DYLD_LIBRARY_PATH: String?
        public var __XCODE_BUILT_PRODUCTS_DIR_PATHS: String?
        public var GPUTOOLS_XCODE_DEVELOPER_PATH: String?
        public var SIMULATOR_CAPABILITIES: String?
        public var SIMULATOR_ROOT: String?
        public var PWD: String?
        
        // MARK: Info.plist
        public var DTPlatformName: String?
        public var DTPlatformVersion: String?
        public var DTSDKName: String?
        public var CFBundleSupportedPlatforms: [String]
        public var MinimumOSVersion: String?
        public var LSMinimumSystemVersion: String?
        public var CFBundleExecutable: String?
        public var CFBundleIdentifier: String?
        public var CFBundleName: String?
        
        // MARK: dyld
        var LC_RPATHs: [String]
        
        private init() {
            let env = ProcessInfo().environment
          
            SIMULATOR_HOST_HOME = env["SIMULATOR_HOST_HOME"]
            DYLD_FRAMEWORK_PATH = (env["DYLD_FRAMEWORK_PATH"] ?? "").components(separatedBy: ":")
            DYLD_LIBRARY_PATH = (env["DYLD_LIBRARY_PATH"] ?? "").components(separatedBy: ":")
            DYLD_INSERT_LIBRARIES = env["DYLD_INSERT_LIBRARIES"]
            __XPC_DYLD_FRAMEWORK_PATH = env["__XPC_DYLD_FRAMEWORK_PATH"]
            __XPC_DYLD_LIBRARY_PATH = env["__XPC_DYLD_LIBRARY_PATH"]
            __XCODE_BUILT_PRODUCTS_DIR_PATHS = env["__XCODE_BUILT_PRODUCTS_DIR_PATHS"]
            GPUTOOLS_XCODE_DEVELOPER_PATH = env["GPUTOOLS_XCODE_DEVELOPER_PATH"]
            SIMULATOR_CAPABILITIES = env["SIMULATOR_CAPABILITIES"]
            SIMULATOR_ROOT = env["SIMULATOR_ROOT"]
            PWD = env["PWD"]
            
            let info = Bundle.main.infoDictionary!
            DTPlatformName = info["DTPlatformName"] as? String
            DTPlatformVersion = info["DTPlatformVersion"] as? String
            DTSDKName = info["DTSDKName"] as? String
            CFBundleSupportedPlatforms = info["CFBundleSupportedPlatforms"] as? [String] ?? []
            MinimumOSVersion = info["MinimumOSVersion"] as? String
            LSMinimumSystemVersion = info["LSMinimumSystemVersion"] as? String
            CFBundleExecutable = info["CFBundleExecutable"] as? String
            CFBundleIdentifier = info["CFBundleIdentifier"] as? String
            CFBundleName = info["CFBundleName"] as? String
            
            // dyld
            LC_RPATHs = Self.LC_RPATHs
        }
        
        static let LC_RPATHs: [String] = { () -> [String] in
            (0..<_dyld_image_count()).reduce(into: []) { rpaths, i in
                guard let header = UnsafeRawPointer(_dyld_get_image_header(i))?.assumingMemoryBound(to: mach_header_64.self) else { return }
                // https://opensource.apple.com/source/xnu/xnu-2050.18.24/EXTERNAL_HEADERS/mach-o/loader.h
                // The load commands directly follow the mach_header
                let load_commands: [UnsafePointer<load_command>] = (1..<header.pointee.ncmds).reduce(into: [UnsafeRawPointer(header.advanced(by: 1)).assumingMemoryBound(to: load_command.self)]) { r, _ in
                    r.append(UnsafeRawPointer(r.last!).advanced(by: Int(r.last!.pointee.cmdsize)).assumingMemoryBound(to: load_command.self))
                }
                let rpath_commands: [UnsafePointer<rpath_command>] = load_commands
                    .filter { $0.pointee.cmd == LC_RPATH }
                    .map { UnsafeRawPointer($0).assumingMemoryBound(to: rpath_command.self) }
                rpaths.append(contentsOf: rpath_commands.map {
                    String(cString: UnsafeRawPointer($0).advanced(by: .init($0.pointee.path.offset)).assumingMemoryBound(to: CChar.self))
                })
            }
        }()
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ProcessInfo._AppDebugInfo {
    /// `/Users/{username}`
    public var estimatedHomeDirectoryURL: URL? {
        (SIMULATOR_HOST_HOME ?? NSHomeDirectory()).map(URL.init(fileURLWithPath:))
    }
    
    /// `/Users/username/Library/Developer/Xcode/DerivedData/app-abcdefg0123456789/Build/Products/Debug-iphonesimulator`
    public var estimatedBuildProductsDirectoryURL: [URL] {
        let a = DYLD_FRAMEWORK_PATH.filter {!$0.isEmpty}.map(URL.init(fileURLWithPath:))
        let b = [(__XPC_DYLD_FRAMEWORK_PATH ?? __XPC_DYLD_LIBRARY_PATH ?? __XCODE_BUILT_PRODUCTS_DIR_PATHS ?? __XPC_DYLD_LIBRARY_PATH ?? PWD).map(URL.init(fileURLWithPath:))].compactMap {$0}
        let c = LC_RPATHs.filter { $0.contains("/DerivedData/") && $0.contains("/Build/Products/") }.map { $0.replacingOccurrences(of: "/PackageFrameworks", with: "")
        }.map(URL.init(fileURLWithPath:))
        
        return a + b + c
    }
    
    /// `/Users/username/Library/Developer/Xcode/DerivedData`
    public var estimataedDerivedData: URL? {
        estimatedBuildProductsDirectoryURL.map {
            URL(fileURLWithPath: $0.path.components(separatedBy: "/")
                .reversed().drop {$0 != "DerivedData"}.reversed()
                .joined(separator: "/"))
        }.first { $0.path.contains("DerivedData") }
    }
    
    /// `app-abcdefg0123456789`
    public var estimatedBuildConfigurationNameBuildRandomString: String? {
        estimatedBuildProductsDirectoryURL.compactMap {
            $0.path.components(separatedBy: "/")
                .drop {$0 != "DerivedData"}
                .dropFirst().first
        }.first
    }
    
    /// app name
    public var estimatedMainModuleName: String? {
        if let result: String = CFBundleExecutable {
            return result
        }
        
        guard let pair = estimatedBuildConfigurationNameBuildRandomString?.components(separatedBy: "-"), pair.count == 2 else {
            return nil
        }
        
        return pair.first
    }
    
    /// Debug
    public var estimatedBuildConfigurationName: String? {
        guard let pair = (estimatedBuildProductsDirectoryURL.compactMap { $0.lastPathComponent.components(separatedBy: "-") }.first) else { return nil }
        return switch pair.count {
            case 1: pair[0]
            case 2: pair[1]
            default: nil
        }
    }
    
    /// Debug-ipphonesimulator
    /// Debug
    public var estimatedBuildConfigurationNamePlatform: String? {
        estimatedBuildProductsDirectoryURL.first?.lastPathComponent
    }
    
    /// iphonesimulator
    public var estimatedPlatformName: String? {
        DTPlatformName
    }
    
    /// `"/Applications/Xcode1501.app/Contents/Developer"`
    public var estimatedDeveloperDirectoryURL: URL? {
        (GPUTOOLS_XCODE_DEVELOPER_PATH ?? (SIMULATOR_CAPABILITIES ?? DYLD_INSERT_LIBRARIES).map {
            $0.components(separatedBy: "/")
                .reversed().drop {$0 != "Platforms"}.dropFirst().reversed()
                .joined(separator: "/")
        }).map(URL.init(fileURLWithPath:))
        ?? (self != .current ? Self.current.estimatedDeveloperDirectoryURL : nil) // on iphoneos, developer dir is not available in env. use host env typically on macOS build helper
    }
    
    /// /Applications/Xcode1501.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.0.sdk
    public var estimatedSDKURL: URL? {
        estimatedDeveloperDirectoryURL?
            .appendingPathComponent("Platforms")
            .appendingPathComponent(estimatedCamelCasePlatformName! + ".platform")
            .appendingPathComponent("Developer/SDKs")
            .appendingPathComponent(estimatedCamelCasePlatformName! + DTPlatformVersion! + ".sdk")
    }
    
    /// For e.g. `"iPhoneSimulator"`.
    public var estimatedCamelCasePlatformName: String? {
        guard let DTPlatformName else {
            return nil
        }
        
        return CFBundleSupportedPlatforms.first { $0.caseInsensitiveCompare(DTPlatformName) == .orderedSame }
    }
    
    public var estimatedDeploymentOSVersion: String? {
        MinimumOSVersion ?? LSMinimumSystemVersion
    }
    
    /// arm64-apple-ios14.0-simulator
    /// arm64-apple-macos13.0
    public var estimatedTargetTriple: String? {
        let os = switch DTPlatformName {
            case "iphoneos", "iphonesimulator": "ios"
            case "macos": "macos"
            case "xros", "xrsimulator": "xros"
            default:
#if os(iOS)
                "ios"
#elseif os(macOS)
                "macos"
#elseif os(visionOS)
                "xros"
#endif
        }
        let isSimulator = DTPlatformName?.contains("simulator") == true
        return [estimatedArch, "apple", os + estimatedDeploymentOSVersion!, isSimulator ? "simulator" : nil]
            .compactMap { $0 }.joined(separator: "-")
    }
    
    /// arm64
    public var estimatedArch: String {
#if arch(arm64)
        "arm64"
#elseif arch(x86_64)
        "x86_64"
#endif
    }
    
    /// Product app bundle on host
    public var estimatedProductBundlePath: [URL] {
        guard let CFBundleName else { return [] }
        return estimatedBuildProductsDirectoryURL.map { $0.appendingPathComponent(CFBundleName).appendingPathExtension("app") }
    }
}

// MARK: - Supplementary

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ProcessInfo {
    public var _isRunningFromWithinXcodeBuildProductsDirectory: Bool? {
        let info = ProcessInfo._AppDebugInfo.current
        
        guard let PWD: URL = info.PWD.flatMap(URL.init(string:)) else {
            return nil
        }
        
        guard !info.estimatedBuildProductsDirectoryURL.isEmpty else {
            return nil
        }
        
        if info.estimatedBuildProductsDirectoryURL.contains(where: { $0.isAncestor(of: PWD) }) {
            return true
        }
        
        return false
    }
}
#endif
