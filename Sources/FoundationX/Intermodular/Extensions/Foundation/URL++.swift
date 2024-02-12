//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import System

extension URL {
    @_disfavoredOverload
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public init?(
        _filePath: FilePath
    ) {
        #if os(visionOS)
        self.init(filePath: _filePath)
        #else
        self.init(fileURLWithPath: String(_filePath))
        #endif
    }
    
    public init?(
        bundle: Bundle,
        fileName: String,
        extension: String?
    ) {
        guard let url = bundle.url(forResource: fileName, withExtension: `extension`) else {
            return nil
        }
        
        self = url
    }
    
    public init?(
        bundle: Bundle,
        fileName: String,
        withOrWithoutExtension `extension`: String
    ) {
        guard let url = URL(bundle: bundle, fileName: fileName, extension: `extension`) ?? URL(bundle: bundle, fileName: fileName, extension: nil) else {
            return nil
        }
        
        self = url
    }
}

extension URL {
    /// The portion of a URL relative to a given base URL.
    public func relativeString(
        relativeTo baseURL: URL
    ) -> String {
        TODO.whole(.addressEdgeCase, .refactor)

        if absoluteString.hasPrefix(baseURL.absoluteString) {
            return absoluteString
                .dropPrefixIfPresent(baseURL.absoluteString)
                .dropPrefixIfPresent("/")
        } else if let host = baseURL.url.host, absoluteString.hasPrefix(host) {
            return absoluteString
                .dropPrefixIfPresent(host)
                .dropPrefixIfPresent("/")
        } else {
            return relativeString
        }
    }
}

extension URL {
    public subscript(keys: Set<URLResourceKey>) -> Result<URLResourceValues, Error> {
        .init(try resourceValues(forKeys: keys))
    }
    
    public subscript(key: URLResourceKey) -> Result<URLResourceValues, Error> {
        self[[key]]
    }

    public mutating func setResourceValues(_ body: (inout URLResourceValues) throws -> Void) throws {
        var values = URLResourceValues()
        
        try body(&values)
        
        try setResourceValues(values)
    }
}

extension URL {
    public static var userDocuments: URL! {
        try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask
        )
    }

    public static func securityAppGroupContainer(
        for identifier: String
    ) throws -> URL {
        try FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: identifier
        ).unwrap()
    }

    /// The real home directory of the user.
    @_spi(Internal)
    public static var _userHomeDirectory: URL {
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
    
    /// Returns the URL for the temporary directory of the current user.
    public static var temporaryDirectory: URL {
        return FileManager.default.temporaryDirectory
    }
}

extension URL {
    /// A file path component suitable for a base URL to append.
    public struct PathComponent: Hashable, Sendable {
        public let rawValue: String
        public let isDirectory: Bool?

        public init(rawValue: String, isDirectory: Bool? = nil) {
            self.rawValue = rawValue
            self.isDirectory = isDirectory
        }
    
        public static func file(_ string: String) -> Self {
            Self(rawValue: string, isDirectory: false)
        }

        public static func directory(_ string: String) -> Self {
            Self(rawValue: string, isDirectory: true)
        }
    }

    public mutating func append(_ component: PathComponent) {
        appendPathComponent(component.rawValue)
    }
    
    @_disfavoredOverload
    public mutating func append(_ component: String) {
        append(PathComponent(rawValue: component))
    }

    public func appending(_ component: PathComponent) -> Self {
        appendingPathComponent(component.rawValue)
    }
    
    @_disfavoredOverload
    public func appending(_ component: String) -> Self {
        appending(PathComponent(rawValue: component))
    }
    
    public static func + (lhs: Self, rhs: PathComponent) -> Self {
        lhs.appending(rhs)
    }

    public func appendingDirectoryPathComponent(
        _ pathComponent: String?
    ) -> URL {
        guard let pathComponent else {
            return self
        }
        
        return appendingPathComponent(pathComponent, isDirectory: true)
    }
}

extension URL {
    @frozen
    public enum _SecurityScopedResourceAccessError: Error {
        case failedToAccessSecurityScopedResource(for: URL)
    }
    
    @_transparent
    public func _accessingSecurityScopedResource<T>(
        _ operation: () throws -> T
    ) throws -> T {
        let isAccessing = self.startAccessingSecurityScopedResource()
        
        guard isAccessing else {
            throw _SecurityScopedResourceAccessError.failedToAccessSecurityScopedResource(for: self)
        }
        
        let result = try operation()
        
        self.stopAccessingSecurityScopedResource()
        
        return result
    }
}

extension URL {
    public var _queryParameters: [String: String]? {
        get {
            guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
                return nil
            }
            
            return queryItems.reduce(into: [String: String]()) { (result, item) in
                result[item.name] = item.value
            }
        } set {
            if newValue.isNilOrEmpty && URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems == nil {
                return
            }
            
            var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
            
            components.queryItems = newValue?.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            
            self = components.url!
        }
    }

    public var _removingPercentEncoding: URL {
        get throws {
            guard let decodedString = self.absoluteString.removingPercentEncoding else {
                throw _PlaceholderError()
            }
            
            return  try URL(string: decodedString).unwrap()
        }
    }
    
    public var _removingQueryParameterValueDelimeters: URL {
        var result = self
        
        result._queryParameters = _queryParameters?.compactMapValues {
            $0.replacingOccurrences(of: "\"", with: "")
        }
        
        return result
    }
}

extension URL {
    public var isWebURL: Bool {
        return scheme == "http" || scheme == "https"
    }

    public var _fileNameWithoutExtension: String {
        self.deletingPathExtension().lastPathComponent
    }

    public var _fileNameWithExtension: String? {
        lastPathComponent
    }

    public var _fileExtension: String {
        pathExtension
    }

    /// Whether the `URL` is `/`.
    public var _isRootPath: Bool {
        return self.path == "/" || resolvingSymlinksInPath().path == "/"
    }
    
    /// Checks if the URL represents a hidden file or directory (i.e., starts with a dot).
    public var _isFileDotPrefixed: Bool {
        self.lastPathComponent.hasPrefix(".")
    }

    /// Checks if the URL represents a directory.
    public var _isKnownOrIndicatedToBeFileDirectory: Bool {
        // Attempt to determine if the URL points to a directory by its path.
        let path = self.path
        var isDirectory = (path.last == "/")
        
        // Use file system to check if path exists and is a directory when possible.
        if self.scheme == "file" {
            var isDir: ObjCBool = false
            
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
                isDirectory = isDir.boolValue
                
                if !isDirectory {
                    let resourceValues = try? self.resourceValues(forKeys: [.isDirectoryKey])
                    
                    if let _isDirectory = resourceValues?.isDirectory, _isDirectory != isDirectory {
                        isDirectory = _isDirectory
                    }
                }
            }
        }
        
        return isDirectory
    }

    /// Adds the missing fucking "/" at the end.
    public var _standardizedDirectoryPath: String {
        path.addingSuffixIfMissing("/")
    }

    /// Returns the immediate ancestor directory if the URL is a file or the URL itself if it is a directory.
    public var _immediateFileDirectory: URL {
        _isKnownOrIndicatedToBeFileDirectory ? self : self.deletingLastPathComponent()
    }

    public func _fromFileURLToURL() -> URL {
        guard isFileURL else {
            return self
        }
        
        return URL(string: resolvingSymlinksInPath().path)!
    }

    public static func temporaryFile(
        name: String,
        data: Data
    ) throws -> URL {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent(name)
        
        try data.write(to: fileURL)
        
        return fileURL
    }
}
