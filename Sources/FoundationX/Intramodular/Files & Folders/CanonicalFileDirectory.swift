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
        case desktop
        case downloads
        case documents
        
        case applicationSupportFiles
        case iCloudDriveDocuments(containerID: String)
        case securityApplicationGroup(String)
        case ubiquityContainer(String)
        case appResources
        case appDocuments
        
        case unspecified
    }
    
    var _name: DirectoryName
    var _unsandboxed: Bool? = nil
    
    init(_name: DirectoryName, _unsandboxed: Bool? = nil) {
        self._name = _name
        self._unsandboxed = _unsandboxed
    }
    
    public static var unspecified: Self {
        Self(_name: .unspecified)
    }
    
    public static func sandboxed(_ name: DirectoryName) -> Self {
        self.init(_name: name, _unsandboxed: false)
    }
    
    public static func unsandboxed(_ name: DirectoryName) -> Self {
        self.init(_name: name, _unsandboxed: true)
    }
}

extension CanonicalFileDirectory {
    public func toURL() throws -> URL {
        let fileManager = FileManager.default
        
        switch _name {
            case .desktop:
                return _UserHomeDirectoryName.desktop.url
            case .downloads:
                return _UserHomeDirectoryName.downloads.url
            case .documents:
                return _UserHomeDirectoryName.documents.url
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
                    .url(
                        forUbiquityContainerIdentifier: identifier
                    )
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
                return Bundle.mainAppBundle.bundleURL
            }
            case .appDocuments: do {
                return try fileManager.url(for: .documentDirectory, in: .userDomainMask)
            }
            case .unspecified:
                throw Never.Reason.illegal
        }
    }
}

extension URL {
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

// MARK: - Supplementary

extension URL {
    public init(
        directory: CanonicalFileDirectory
    ) throws {
        self = try directory.toURL()
    }
}

extension Bundle {
    fileprivate static var mainAppBundle: Bundle {
        // Bundle.main always points to the main application bundle in an app context
        return Bundle.main
    }
}
