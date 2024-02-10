//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Shorthands for standard file directories.
///
/// Written to improve API ergonomics.
public struct CanonicalFileDirectory: Hashable, Sendable {
    public enum _DirectoryName: Hashable, Sendable {
        case desktop
        case downloads
        case documents
        
        case applicationSupportFiles
        case iCloudDriveDocuments(containerID: String)
        case securityApplicationGroup(String)
        case ubiquityContainer(String)
        case appDocuments
    }
    
    var _name: _DirectoryName
    var _unsandboxed: Bool? = nil
}

extension CanonicalFileDirectory {
    public static var desktop: Self {
        Self(_name: .desktop)
    }
    
    public static var downloads: Self {
        Self(_name: .downloads)
    }
    
    public static var documents: Self {
        Self(_name: .documents)
    }
    
    public static var applicationSupportFiles: Self {
        Self(_name: .applicationSupportFiles)
    }
    
    public static func iCloudDriveDocuments(containerID: String) -> Self {
        Self(_name: .iCloudDriveDocuments(containerID: containerID))
    }
    
    public static func securityApplicationGroup(_ id: String) -> Self {
        Self(_name: .securityApplicationGroup(id))
    }
    
    public static func ubiquityContainer(_ id: String) -> Self {
        Self(_name: .ubiquityContainer(id))
    }
    
    public static var appDocuments: Self {
        Self(_name: .appDocuments)
    }
    
    public static var userDocuments: Self {
        Self(_name: .appDocuments)
    }
}

extension CanonicalFileDirectory {
    public func toURL() throws -> URL {
        let fileManager = FileManager.default
        
        switch _name {
            case .desktop:
                return try _UserHomeDirectory.desktop.url
            case .downloads:
                return try _UserHomeDirectory.downloads.url
            case .documents:
                return try _UserHomeDirectory.documents.url
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
            case .appDocuments: do {
                return try fileManager.url(for: .documentDirectory, in: .userDomainMask)
            }
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
