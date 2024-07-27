//
// Copyright (c) Vatsal Manot
//

import Foundation
@_spi(Internal) import Swallow

extension URL {
    public final class _SavedBookmarks: @unchecked Sendable {
        private static let lock = OSUnfairLock()
        
        @UserDefault(
            "Foundation.URL._SavedBookmarks.items",
            store: UserDefaults(suiteName: "com.vmanot.Swallow")!
        )
        static var items: IdentifierIndexingArrayOf<URL.Bookmark> = []
        
        public static func bookmark(
            _ url: URL
        ) throws -> URL {
            do {
                if !FileManager.default.fileExists(at: url) {
                    runtimeIssue("Scoped bookmarks can only be created for existing files or directories. \(url) does not exist.")
                    
                    return url
                }
                
                let bookmarkData = try url._bookmarkDataWithSecurityScopedAccess()
                let bookmark = try URL.Bookmark(data: bookmarkData, allowStale: true)
                
                Task.detached(priority: .utility) {
                    lock.withCriticalScope {
                        self.items[id: bookmark.id] = bookmark
                    }
                }
                
                return try bookmark.toURL()
            } catch {
                throw _Error.failedToSaveBookmarkData(error)
            }
        }
        
        public static func bookmarkedURL(
            for url: any URLRepresentable
        ) throws -> URL? {
            let result: URL? = try lock.withCriticalScope { () -> URL? in
                try self.items[id: URL.Bookmark.ID(from: url.url)]?.toURL()
            }
            
            guard let result else {
                return nil
            }
            
            return result
        }
        
        @available(*, deprecated, renamed: "bookmarkedURL")
        public static func cachedURL(
            for url: any URLRepresentable
        ) throws -> URL? {
            try bookmarkedURL(for: url)
        }
        
        public static func removeAll() {
            lock.withCriticalScope {
                items = []
            }
        }
    }
}

// MARK: - Auxiliary

extension URL {
    /// Determines if the URL is likely exempt from requiring security-scoped access based on known directories.
    public var isKnownSecurityScopedAccessExempt: Bool {
        // Known directories that are typically exempt from requiring security-scoped access
        let knownDirectories: [FileManager.SearchPathDirectory] = [
            .applicationDirectory,
            .documentDirectory,
            .cachesDirectory,
            .applicationSupportDirectory,
            .downloadsDirectory
        ]
        
        let fileManager = FileManager.default
        
        // Check if the URL is within any of the known directories
        for directory in knownDirectories {
            do {
                let directoryURL: URL
                directoryURL = try fileManager.url(
                    for: directory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                
                if self.standardizedFileURL.absoluteString.hasPrefix(directoryURL.standardizedFileURL.absoluteString) {
                    return false // The URL is within a known directory and likely doesn't require security-scoped access
                }
            } catch {
                // If we cannot get the URL for a directory, ignore and continue checking others
                continue
            }
        }
        
        // Additional checks for specific known paths or exemptions can be added here
        
        // If the URL is not within any known directories, it likely requires security-scoped access
        return true
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
extension URL {
    init(
        _resolvingBookmarkDataWithSecurityScopedAccess data: Data,
        isStale: inout Bool
    ) throws {
        throw Never.Reason.unsupported
    }
    
    func _bookmarkDataWithSecurityScopedAccess() throws -> Data {
        throw Never.Reason.unsupported
    }
}
#else
extension URL {
    init(
        _resolvingBookmarkDataWithSecurityScopedAccess data: Data,
        isStale: inout Bool
    ) throws {
        try self.init(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
    
    func _bookmarkDataWithSecurityScopedAccess() throws -> Data {
        let fileURL: URL = _fromURLToFileURL()
        
        return try fileURL.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
}
#endif

// MARK: - Error Handling

@_spi(Internal)
extension URL._SavedBookmarks {
    public enum _Error: Error {
        case failedToSaveBookmarkData(Error)
        case unxpectedlyStale(URL)
    }
}
