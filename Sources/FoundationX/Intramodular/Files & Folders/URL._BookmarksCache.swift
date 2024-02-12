//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension URL {
    public final class _BookmarksCache {
        private static let defaults = UserDefaults(suiteName: Swallow._module.bundleIdentifier)!
        private static let bookmarkKey = "SecurityScopedBookmarks"
        
        struct Bookmark: Codable {
            let urlPath: String
            var data: Data
        }
        
        public static func save(
            for url: URL
        ) throws -> URL {
            do {
                let url = url.standardized
                
                let bookmarkData = try url._bookmarkDataWithSecurityScopedAccess()
                var bookmarks = load()
                
                if let index = bookmarks.firstIndex(where: { $0.urlPath == url.path }) {
                    bookmarks[index].data = bookmarkData
                } else {
                    bookmarks.append(Bookmark(urlPath: url.path, data: bookmarkData))
                }
                
                save(bookmarks)
                
                return try resolvedURL(for: url)!
            } catch {
                throw _Error.failedToSaveBookmarkData(error)
            }
        }
        
        public static func resolvedURL(
            for url: URL
        ) throws -> URL? {
            let url = url.standardized
            
            guard let bookmark = load().first(where: { $0.urlPath == url.path }) else {
                return nil
            }
            
            var isStale = false
            
            do {
                let resolvedURL = try URL(
                    _resolvingBookmarkDataWithSecurityScopedAccess: bookmark.data,
                    isStale: &isStale
                )
                
                if !isStale {
                    return resolvedURL
                } else {
                    return nil
                }
            } catch {
                throw URL._BookmarksCache._Error.failedToSaveBookmarkData(error)
            }
        }
        
        private static func save(
            _ bookmarks: [Bookmark]
        ) {
            do {
                let data = try JSONEncoder().encode(bookmarks)
                
                defaults.set(data, forKey: bookmarkKey)
            } catch {
                print("Error saving bookmarks: \(error)")
            }
        }
        
        private static func load() -> [Bookmark] {
            guard let data = defaults.data(forKey: bookmarkKey) else { return [] }
            do {
                return try JSONDecoder().decode([Bookmark].self, from: data)
            } catch {
                print("Error loading bookmarks: \(error)")
                return []
            }
        }
        
        private static func removeAll() {
            defaults.removeObject(forKey: bookmarkKey)
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
                directoryURL = try fileManager.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: false)
                
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

#if os(iOS) || os(tvOS) || os(visionOS)
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
        try bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
}
#endif

// MARK: - Error Handling

extension URL._BookmarksCache {
    public enum _Error: Error {
        case failedToSaveBookmarkData(Error)
        case unxpectedlyStale(URL)
    }
}
