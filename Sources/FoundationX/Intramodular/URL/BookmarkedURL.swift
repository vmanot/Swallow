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
        FilePath(url)!
    }
    
    public init?(url: URL, bookmarkData: Data?) {
        self.url = url
        self.bookmarkData = bookmarkData
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
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            url = try container.decode(URL.self, forKey: .url)
            bookmarkData = try container.decodeIfPresent(Data.self, forKey: .bookmarkData)
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
        guard let url = URL(FilePath(rawValue)) else {
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

