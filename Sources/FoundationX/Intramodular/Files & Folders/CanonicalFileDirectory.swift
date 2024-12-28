//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Shorthands for standard file directories.
///
/// Written to improve API ergonomics.
public struct CanonicalFileDirectory: Hashable, Sendable {
    public enum DirectoryName: Hashable, Sendable {
        case applications
        case userHomeDirectory(_UserHomeDirectoryName)
        case applicationSupportFiles
        case iCloudDriveDocuments(containerID: String)
        case securityApplicationGroup(String)
        case ubiquityContainer(String)
        case appResources
        case appDocuments
        case xcodeDerivedData
        
        case unspecified
    }
    
    var _name: DirectoryName
    var _isUnsandboxed: Bool? = nil
    
    public var url: URL {
        try! toURL()
    }
    
    public var path: String {
        url.path
    }
    
    init(_name: DirectoryName, _unsandboxed: Bool? = nil) {
        self._name = _name
        self._isUnsandboxed = _unsandboxed
    }
    
    public static var unspecified: Self {
        Self(_name: .unspecified)
    }
    
    public func _unsandboxed() -> Self {
        withMutableScope(self) {
            $0._isUnsandboxed = true
        }
    }
}

extension CanonicalFileDirectory {
    public func toURL() throws -> URL {
        let fileManager = FileManager.default
        
        switch _name {
            case .applications:
                if let _isUnsandboxed, _isUnsandboxed {
                    return URL(fileURLWithPath: "/Applications")
                } else {
                    return FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first!
                }
            case .userHomeDirectory(let directory): do {
                return directory._url(unsandboxed: _isUnsandboxed)
            }
            case .applicationSupportFiles: do {
                return try fileManager
                    .url(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true
                    )
            }
            case .iCloudDriveDocuments(let identifier): do {
                return try fileManager
                    .url(forUbiquityContainerIdentifier: identifier)
                    .unwrap()
                    .appendingDirectoryPathComponent("Documents")
            }
            case .securityApplicationGroup(let identifier): do {
                return try fileManager
                    .containerURL(forSecurityApplicationGroupIdentifier: identifier)
                    .unwrap()
            }
            case .ubiquityContainer(let identifier): do {
                return try fileManager
                    .url(forUbiquityContainerIdentifier: identifier)
                    .unwrap()
            }
            case .appResources: do {
                return Bundle.main.bundleURL
            }
            case .appDocuments: do {
                return try fileManager.url(for: .documentDirectory, in: .userDomainMask)
            }
            case .xcodeDerivedData:
                return URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Developer/Xcode/DerivedData")
            case .unspecified:
                throw CanonicalFileDirectory.Error.directoryNotSpecified
        }
    }
}

extension CanonicalFileDirectory {
    public static func + (
        lhs: Self,
        rhs: String
    ) throws -> URL {
        try lhs.toURL().appendingPathComponent(rhs)
    }
    
    public static func + (
        lhs: Self,
        rhs: URL.PathComponent
    ) throws -> URL {
        try lhs.toURL().appending(rhs)
    }
    
    /// Returns the first valid location of the two given operands.
    public static func || (
        lhs: Self,
        rhs: Self
    ) -> Self {
        do {
            _ = try lhs.toURL()
            
            return lhs
        } catch {
            return rhs
        }
    }
}

// MARK: - Error Handling

extension CanonicalFileDirectory {
    public enum Error: Swift.Error {
        case directoryNotSpecified
    }
}

// MARK: - Supplementary

extension URL {
    public init(
        directory: CanonicalFileDirectory
    ) throws {
        self = try directory.toURL()
    }
    
    public init(
        directory: CanonicalFileDirectory,
        path: String
    ) throws {
        self = try directory + path
    }
    
    public init(
        directory: CanonicalFileDirectory,
        subdirectory: String,
        filename: String
    ) throws {
        self = (try directory + subdirectory).appendingPathComponent(filename, isDirectory: false)
    }
}
