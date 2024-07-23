//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift
import System

@frozen
public struct BookmarkedURL: Identifiable, URLRepresentable {
    public let url: URL
    public let bookmarkData: Data?
    
    @inlinable
    public var id: some Hashable {
        url
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    @inlinable
    public var path: FilePath {
        FilePath(url.absoluteString)
    }
    
    public init?(url: URL, bookmarkData: Data?) {
        self.url = url
        self.bookmarkData = bookmarkData
    }
    
    public init(url: URL, bookmarkCreationOptions: URL.BookmarkCreationOptions) throws {
        self.url = url
        self.bookmarkData = try URL.Bookmark(for: url).data
    }
    
    public init?(url: URL) {
        self.init(url: url, bookmarkData: try? url.bookmarkData())
    }
    
    @inlinable
    public init(_unsafe url: URL) {
        self.url = url
        self.bookmarkData = nil
    }
}

// MARK: - Extensions

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension BookmarkedURL {
    public var hasChildren: Bool {
        do {
            return try !FileManager.default
                .suburls(at: url)
                .map(BookmarkedURL.init(_unsafe:))
                .filter({ FileManager.default.fileExists(at: $0.path) })
                .isEmpty
        } catch {
            return false
        }
    }
    
    public var isEmpty: Bool {
        let result = try? FileManager.default
            .suburls(at: url)
            .map(BookmarkedURL.init(_unsafe:))
            .filter({ FileManager.default.fileExists(at: $0.path) })
        
        return result?.isEmpty ?? false
    }
}

// MARK: - Conformances

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension BookmarkedURL: Codable {
    public enum CodingKeys: String, CodingKey {
        case url
        case bookmarkData
    }
    
    public func encode(to encoder: Encoder) throws {
        if let bookmarkData = bookmarkData {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(url, forKey: .url)
            try container.encode(bookmarkData, forKey: .bookmarkData)
        } else {
            var container = encoder.singleValueContainer()
            
            try container.encode(rawValue)
        }
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            
            do {
                self = try Self(rawValue: try container.decode(String.self)).unwrap()
            } catch {
                self = try Self(url: try container.decode(URL.self)).unwrap()
            }
        } catch {
            if let bookmark = try? URL.Bookmark(from: decoder) {
                self = try Self(url: try bookmark.resolve().url).unwrap()
            } else {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                do {
                    self.url = try container.decode(URL.self, forKey: .url)
                } catch {
                    let urlString = try container.decode(String.self, forKey: .url)
                    
                    assert(urlString.hasPrefix("file://"))
                    
                    self.url = try URL(string: urlString).unwrap()
                }
                
                do {
                    bookmarkData = try container.decodeIfPresent(Data.self, forKey: .bookmarkData)
                } catch {
                    bookmarkData = Data(base64Encoded: try container.decodeIfPresent(String.self, forKey: .bookmarkData).unwrap())
                }
            }
        }
    }
}

extension BookmarkedURL: CustomStringConvertible {
    public var description: String {
        url.description
    }
}

extension BookmarkedURL: Equatable {
    public static func == (lhs: Self, rhs: URL) -> Bool {
        lhs.url == rhs
    }
    
    public static func != (lhs: Self, rhs: URL) -> Bool {
        lhs.url != rhs
    }
    
    public static func == (lhs: URL, rhs: Self) -> Bool {
        lhs == rhs.url
    }
    
    public static func != (lhs: URL, rhs: Self) -> Bool {
        lhs != rhs.url
    }
}

extension BookmarkedURL: Hashable {
    public func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension BookmarkedURL: RawRepresentable  {
    public var rawValue: String {
        url.path
    }
    
    public init?(rawValue: String) {
        guard let url = URL(_filePath: FilePath(rawValue)) else {
            return nil
        }
        
        self.init(_unsafe: url)
    }
}

// MARK: - Helpers

extension BookmarkedURL {
    public func discardingBookmarkData() -> BookmarkedURL {
        BookmarkedURL(url: url, bookmarkData: nil)!
    }
}

