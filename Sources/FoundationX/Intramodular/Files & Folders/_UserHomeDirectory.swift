//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import System

public enum _UserHomeDirectory: String, CaseIterable {
    case desktop = "Desktop"
    case documents = "Documents"
    case music = "Music"
    case library = "Library"
    case downloads = "Downloads"
    case movies = "Movies"
    case pictures = "Pictures"
    case publicDirectory = "Public"
    
    public var url: URL {
        get throws {
            let url = try URL._userHomeDirectory.appendingPathComponent(self.rawValue)
            
            return try _SecurityScopedBookmarks.resolvedURL(for: url) ?? url
        }
    }
    
    public init?(from url: URL) {
        let standardizedPath = url.standardizedFileURL.path
        
        guard let directory = Self.allCases.first(where: { directory -> Bool in
            do {
                return (try directory.url.standardizedFileURL.path) == standardizedPath
            } catch {
                runtimeIssue(error)
                
                return false
            }
        }) else {
            return nil
        }
        
        self = directory
    }
    
    public func requestAccess() async throws -> URL {
        try await _DirectoryAccessManager.requestAccess(to: self)
    }
}

extension _UserHomeDirectory {
    private enum DirectoryError: Error {
        case unreadablePath
        case invalidHomeDirectory
        case invalidURL
    }
}
