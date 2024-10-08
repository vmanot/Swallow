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
        static var items: [URL.Bookmark.ID: URL.Bookmark] = [:]
        
        public static func bookmark(
            _ url: URL
        ) throws -> URL {
            do {
                if !FileManager.default.fileExists(at: url) {
                    throw URL.ScopedBookmarkCreationError.fileDoesNotExist(url)
                }
                
                let bookmarkData: Data = try url._bookmarkDataWithSecurityScopedAccess()
                let bookmark = try URL.Bookmark(data: bookmarkData, allowStale: true)

                let result: URL = try bookmark.toURL()

                lock.withCriticalScope {
                    self.items[URL.Bookmark.ID(from: url)] = bookmark
                    self.items[bookmark.id] = bookmark
                }
                
                if result._isSandboxedURL == true && url._isSandboxedURL == false {
                    return url
                } else {
                    return result
                }
            } catch {
                throw _Error.failedToSaveBookmarkData(error)
            }
        }
        
        public static func bookmarkedURL(
            for url: any URLRepresentable
        ) throws -> URL? {
            let url: URL = url.url
            let result: URL? = try lock.withCriticalScope { () -> URL? in
                guard let existingBookmark: URL.Bookmark = self.items[URL.Bookmark.ID(from: url)] else {
                    return nil
                }
                
                var bookmark = existingBookmark
                
                _ = try? bookmark.renew()
                                                
                return try bookmark.toURL()
            }
            
            guard let result else {
                return nil
            }
            
            guard url._isSandboxedURL == result._isSandboxedURL else {
                return url
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
                items = [:]
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
    public enum _Error: Swift.Error {
        case failedToCreateScopedBookmark(URL.ScopedBookmarkCreationError)
        case failedToSaveBookmarkData(Error)
        case unxpectedlyStale(URL)
    }
}

extension URL {
    public enum ScopedBookmarkCreationError: Swift.Error {
        case fileDoesNotExist(URL)
    }
}
