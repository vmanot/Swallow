//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import System

public enum _UserHomeDirectoryName: String, CaseIterable, URLConvertible {
    case home = "~"
    case desktop = "Desktop"
    case documents = "Documents"
    case music = "Music"
    case library = "Library"
    case downloads = "Downloads"
    case movies = "Movies"
    case pictures = "Pictures"
    case publicDirectory = "Public"
    
    public var url: URL {
        try! URL._realHomeDirectory.appendingPathComponent(self.rawValue)
    }
    
    public init?(from url: URL) {
        let standardizedPath: String = url.standardizedFileURL.path
        
        guard let directory: Self = Self.allCases.first(where: { directory -> Bool in
            return directory.url.standardizedFileURL.path == standardizedPath
        }) else {
            return nil
        }
        
        self = directory
    }
    
    @MainActor
    func requestAccess() async throws -> URL {
        try URL._FileOrDirectorySecurityScopedAccessManager.requestAccess(to: self)
    }
}

extension _UserHomeDirectoryName {
    private var _tildePath: String {
        switch self {
            case .home:
                return "~"
            case .desktop:
                return "~/Desktop"
            case .documents:
                return "~/Documents"
            case .music:
                return "~/Music"
            case .library:
                return "~/Library"
            case .downloads:
                return "~/Downloads"
            case .movies:
                return "~/Movies"
            case .pictures:
                return "~/Pictures"
            case .publicDirectory:
                return "~/Public"
        }
    }
}

extension _UserHomeDirectoryName {
    private enum DirectoryError: Error {
        case unreadablePath
        case invalidHomeDirectory
        case invalidURL
    }
}

// MARK: - Auxiliary

extension URL {
    /// The real home directory of the user.
    static var _realHomeDirectory: URL {
        @_disfavoredOverload
        get throws {
            enum _Error: Swift.Error {
                case invalidHomeDirectory
            }
            
            guard let pw = getpwuid(getuid()), let home = pw.pointee.pw_dir else {
                throw _Error.invalidHomeDirectory
            }
            
            let path = FileManager.default.string(
                withFileSystemRepresentation: home,
                length: Int(strlen(home))
            )
            
            return URL(fileURLWithPath: path)
        }
    }
}
