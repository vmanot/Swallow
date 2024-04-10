//
// Copyright (c) Vatsal Manot
//

import CoreTransferable
import Foundation
import Swallow

extension URL {
    /// A type representing URL bookmark data.
    public struct Bookmark: Hashable, Sendable {
        public let data: Data
        public let creationOptions: URL.BookmarkCreationOptions
        
        private init(
            data: Data,
            creationOptions: URL.BookmarkCreationOptions
        ) {
            self.data = data
            self.creationOptions = creationOptions
        }
        
        public init(
            for url: URL,
            creationOptions: URL.BookmarkCreationOptions = []
        ) throws {
            self.data = try url.bookmarkData(
                options: creationOptions,
                includingResourceValuesForKeys: [],
                relativeTo: nil
            )
            self.creationOptions = creationOptions
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(data)
            hasher.combine(creationOptions.rawValue)
        }
    }
}

extension URL.Bookmark: Codable {
    public enum CodingKeys: String, CodingKey {
        case data
        case creationOptions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.data = try container.decode(Data.self, forKey: .data)
        self.creationOptions = .init(rawValue: try container.decode(URL.BookmarkCreationOptions.RawValue.self, forKey: .creationOptions))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(data, forKey: .data)
        try container.encode(creationOptions.rawValue, forKey: .creationOptions)
    }
}

extension URL.Bookmark {
    /// Returns a URL by resolving the bookmark.
    public func resolve() throws -> (url: URL, wasStale: Bool) {
        var isStale = false
        
        let url = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
        
        return (url, isStale)
    }
    
    /// Renews the bookmark if it is stale.
    public mutating func renew() throws {
        let (url, wasStale) = try resolve()
        
        guard wasStale else {
            return
        }
        
        let newBookmarkData: Data
        
        #if os(macOS)
        if creationOptions.contains(.withSecurityScope) {
            guard url.startAccessingSecurityScopedResource() else {
                throw Error.couldNotAccessWithSecureScope(url)
            }
            
            newBookmarkData = try url.bookmarkData(
                options: creationOptions,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            url.stopAccessingSecurityScopedResource()
        } else {
            newBookmarkData = try url.bookmarkData(
                options: creationOptions,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        }
        #else
        newBookmarkData = try url.bookmarkData(
            options: creationOptions,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        #endif
        
        self = .init(data: newBookmarkData, creationOptions: creationOptions)
    }
}

// MARK: - Conformances

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension URL.Bookmark: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CoreTransferable.ProxyRepresentation(
            exporting: { (bookmark: URL.Bookmark) -> URL in
                try URL(resolving: bookmark)
            }
        )
    }
}

// MARK: - Supplementary

extension URL {
    /// Creates a URL that refers to a location specified by resolving a given bookmark.
    public init(resolving bookmark: Bookmark) throws {
        self = try bookmark.resolve().url
    }
}

// MARK: - Auxiliary

extension URL.Bookmark {
    public enum Error: Swift.Error {
        case couldNotAccessWithSecureScope(URL)
    }
}
