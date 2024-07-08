//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import System

public enum _UserHomeDirectoryName: String, CaseIterable, Sendable, URLConvertible {
    case home = "~"
    case desktop = "Desktop"
    case documents = "Documents"
    case music = "Music"
    case library = "Library"
    case downloads = "Downloads"
    case movies = "Movies"
    case pictures = "Pictures"
    case sharedPublicDirectory = "Public"
    
    public var url: URL {
        _sandboxedURL
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
    static var _allUnsandboxedPaths: Set<String> = Set(_UserHomeDirectoryName.allCases.map(\.url).map(\._unsandboxedURL).map(\.path))
    
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
            case .sharedPublicDirectory:
                return "~/Public"
        }
    }
    
    var _sandboxedURL: URL! {
        switch self {
            case .home:
                return URL(fileURLWithPath: NSHomeDirectory())
            case .desktop:
                return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
            case .documents:
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            case .music:
                return FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first
            case .library:
                return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
            case .downloads:
                return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            case .movies:
                return FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first
            case .pictures:
                return FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first
            case .sharedPublicDirectory:
                return FileManager.default.urls(for: .sharedPublicDirectory, in: .userDomainMask).first
        }
    }
    
    var _unsandboxedURL: URL! {
        _sandboxedURL._unsandboxedURL
    }
    
    func url(unsandboxed: Bool?) -> URL {
        if let unsandboxed: Bool {
            if unsandboxed {
                return _unsandboxedURL
            } else {
                return _sandboxedURL // FIXME: Use smart defaults
            }
        } else {
            return _sandboxedURL
        }
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
    
    public var _hasUserHomeDirectoryPrefix: Bool {
        if path == URL(fileURLWithPath: NSHomeDirectory())._unsandboxedURL.path {
            return true
        }
        
        return _UserHomeDirectoryName._allUnsandboxedPaths.contains(self.path)
    }
}

// MARK: - Error Handling

extension _UserHomeDirectoryName {
    private enum DirectoryError: Error {
        case unreadablePath
        case invalidHomeDirectory
        case invalidURL
    }
}
