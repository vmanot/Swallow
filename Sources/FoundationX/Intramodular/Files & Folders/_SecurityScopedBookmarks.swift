//
// Copyright (c) Vatsal Manot
//

import Foundation

class _SecurityScopedBookmarks {
    private static let defaults = UserDefaults(suiteName: "com.vmanot.Swallow")!
    private static let bookmarkKey = "SecurityScopedBookmarks"
    
    struct Bookmark: Codable {
        let urlPath: String
        var data: Data
    }
    
    private static func standardizedURL(from url: URL) -> URL {
        return url.standardized
    }
    
    static func save(for url: URL) throws -> URL {
        do {
            let standardizedURL = self.standardizedURL(from: url)
            
            let bookmarkData = try standardizedURL._bookmarkDataWithSecurityScopedAccess()
            var bookmarks = load()
            
            if let index = bookmarks.firstIndex(where: { $0.urlPath == standardizedURL.path }) {
                bookmarks[index].data = bookmarkData
            } else {
                bookmarks.append(Bookmark(urlPath: standardizedURL.path, data: bookmarkData))
            }
            
            save(bookmarks)
            
            return try resolvedURL(for: url)!
        } catch {
            throw _Error.failedToSaveBookmarkData(error)
        }
    }
        
    static func resolvedURL(
        for url: URL
    ) throws -> URL? {
        let standardizedURL = self.standardizedURL(from: url)
       
        guard let bookmark = load().first(where: { $0.urlPath == standardizedURL.path }) else {
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
                throw _Error.unxpectedlyStale(resolvedURL)
            }
        } catch {
            throw _SecurityScopedBookmarks._Error.failedToSaveBookmarkData(error)
        }
    }
    
    private static func save(_ bookmarks: [Bookmark]) {
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

    private static func clear() {
        defaults.removeObject(forKey: bookmarkKey)
    }
}

// MARK: - Auxiliary

#if os(iOS)
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

extension _SecurityScopedBookmarks {
    public enum _Error: Error {
        case failedToSaveBookmarkData(Error)
        case unxpectedlyStale(URL)
    }
}
