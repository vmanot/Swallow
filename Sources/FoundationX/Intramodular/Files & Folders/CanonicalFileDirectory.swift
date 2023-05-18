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
    case applicationSupportFiles
    case iCloudDriveDocuments(ubiquityContainerIdentifier: String)
    case securityApplicationGroup(String)
    case ubiquityContainer(String)
    case userDocuments
    
    public func toURL() throws -> URL {
        let fileManager = FileManager.default
        
        switch self {
            case .desktop:
                return try fileManager.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            case .applicationSupportFiles:
                return try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            case .iCloudDriveDocuments(let identifier):
                return try fileManager.url(forUbiquityContainerIdentifier: identifier).unwrap().appendingDirectoryPathComponent("Documents")
            case .securityApplicationGroup(let identifier):
                return try fileManager.containerURL(forSecurityApplicationGroupIdentifier: identifier).unwrap()
            case .ubiquityContainer(let identifier):
                return try fileManager.url(forUbiquityContainerIdentifier: identifier).unwrap()
            case .userDocuments:
                return try fileManager.url(for: .documentDirectory, in: .userDomainMask)
        }
    }
}


extension CanonicalFileDirectory {
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

// MARK: - Supplementary API

extension URL {
    public init(directory: CanonicalFileDirectory) throws {
        self = try directory.toURL()
    }
}
