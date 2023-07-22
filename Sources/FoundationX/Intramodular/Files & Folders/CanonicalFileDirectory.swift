//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Shorthands for standard file directories.
///
/// Written to improve API ergonomics.
public enum CanonicalFileDirectory {
    case desktop
    case downloads
    
    case applicationSupportFiles
    case iCloudDriveDocuments(containerID: String)
    case securityApplicationGroup(String)
    case ubiquityContainer(String)
    case userDocuments
    
    public func toURL() throws -> URL {
        let fileManager = FileManager.default
        
        switch self {
            case .desktop: do {
                return try fileManager
                    .url(
                        for: .desktopDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true
                    )
            }
            case .downloads: do {
                return try fileManager
                    .url(
                        for: .downloadsDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true
                    )
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
            case .userDocuments: do {
                return try fileManager
                    .url(for: .documentDirectory, in: .userDomainMask)
            }
        }
    }
}

extension CanonicalFileDirectory {
    public static func + (lhs: Self, rhs: String) throws -> URL {
        try lhs.toURL().appendingPathComponent(rhs)
    }

    public static func + (lhs: Self, rhs: URL.PathComponent) throws -> URL {
        try lhs.toURL().appending(rhs)
    }

    /// Returns the first valid location of the two given operands.
    public static func || (lhs: Self, rhs: Self) -> Self {
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
    public init(directory: CanonicalFileDirectory) throws {
        self = try directory.toURL()
    }
}
