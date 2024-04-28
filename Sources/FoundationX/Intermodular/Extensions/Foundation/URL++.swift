//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow
import System
import UniformTypeIdentifiers

extension URL {
    @_disfavoredOverload
    public init(_ url: URL, _: Void = ()) {
        self = url
    }
}

extension URL {
    @_disfavoredOverload
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public init?(
        _filePath: FilePath
    ) {
#if os(visionOS)
        self.init(filePath: _filePath)
#else
        self.init(fileURLWithPath: String(decoding: _filePath))
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
    
    @_disfavoredOverload
    public init(
        _filePath path: String?
    ) throws {
        try self.init(fileURLWithPath: path.unwrap())
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
        @_disfavoredOverload
        get {
            try? FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask
            )
        }
    }
    
    @_disfavoredOverload
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
    
    /// Returns the URL for the temporary directory of the current user.
    @_disfavoredOverload
    public static var temporaryDirectory: URL {
        @_disfavoredOverload
        get {
            return FileManager.default.temporaryDirectory
        }
    }
}

extension URL {
    /// A file path component suitable for a base URL to append.
    public struct PathComponent: ExpressibleByStringLiteral, Codable, Hashable, Sendable {
        public let rawValue: String
        public let isDirectory: Bool?
        
        public init(rawValue: String, isDirectory: Bool? = nil) {
            self.rawValue = rawValue
            self.isDirectory = isDirectory
        }
        
        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
        
        public init(_ value: String) {
            self.init(rawValue: value)
        }
        
        public static func file(_ string: String) -> Self {
            Self(rawValue: string, isDirectory: false)
        }
        
        public static func directory(_ string: String) -> Self {
            Self(rawValue: string, isDirectory: true)
        }
    }
    
    public struct RelativePath: Codable, Hashable, Sendable {
        public let components: [URL.PathComponent]
        
        public var path: String {
            components.map(\.rawValue).joined(separator: "/")
        }
        
        public init(components: [URL.PathComponent]) {
            self.components = components
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
    
    public func appending(_ path: RelativePath) -> Self {
        path.components.reduce(into: self, { $0.append($1) })
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
    
    public func path(
        relativeTo baseURL: URL
    ) throws -> RelativePath {
        guard baseURL.scheme != nil, baseURL.host != nil else {
            throw URLError(.badURL)
        }
        
        guard self.scheme != nil, self.host != nil else {
            throw URLError(.badURL)
        }
        
        guard self.absoluteString.hasPrefix(baseURL.absoluteString) else {
            throw URLError(.badURL)
        }
        
        let relativeString = self.absoluteString.replacingOccurrences(of: baseURL.absoluteString, with: "")
        let trimmedString = relativeString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        let components = trimmedString.components(separatedBy: "/")
        
        return RelativePath(components: components.map({ URL.PathComponent(rawValue: $0) }))
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
        do {
            let isAccessing = self.startAccessingSecurityScopedResource()
            
            guard isAccessing else {
                throw _SecurityScopedResourceAccessError.failedToAccessSecurityScopedResource(for: self)
            }
            
            let result = try operation()
            
            self.stopAccessingSecurityScopedResource()
            
            return result
        } catch {
            if let accessibleAncestor = FileManager.default.nearestAccessibleSecurityScopedAncestor(for: url) {
                let isAccessing = accessibleAncestor.startAccessingSecurityScopedResource()
                
                guard isAccessing else {
                    throw _SecurityScopedResourceAccessError.failedToAccessSecurityScopedResource(for: self)
                }
                
                let result = Result(catching: {
                    try operation()
                })
                
                accessibleAncestor.stopAccessingSecurityScopedResource()
                
                return try result.get()
            }
            
            throw error
        }
    }
    
    @_transparent
    public func _accessingSecurityScopedResource<T>(
        _ operation: () async throws -> T
    ) async throws -> T {
        do {
            let isAccessing = self.startAccessingSecurityScopedResource()
            
            guard isAccessing else {
                throw _SecurityScopedResourceAccessError.failedToAccessSecurityScopedResource(for: self)
            }
            
            let result = await Result(catching: {
                try await operation()
            })
            
            self.stopAccessingSecurityScopedResource()
            
            return try result.get()
        } catch {
            if let accessibleAncestor = FileManager.default.nearestAccessibleSecurityScopedAncestor(for: url) {
                let isAccessing = accessibleAncestor.startAccessingSecurityScopedResource()
                
                guard isAccessing else {
                    throw _SecurityScopedResourceAccessError.failedToAccessSecurityScopedResource(for: self)
                }

                let result = await Result(catching: {
                    try await operation()
                })

                accessibleAncestor.stopAccessingSecurityScopedResource()
                
                return try result.get()
            }
            
            throw error
        }
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
    
    public var _filePath: String {
        resolvingSymlinksInPath().path
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
    
    public var _actuallyStandardizedFileURL: URL {
        URL(fileURLWithPath: standardizedFileURL.path)
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
        if FileManager.default.isDirectory(at: self) {
            return true
        }
                
        if self.path.last == "/" || self.absoluteString.last == "/" {
            return true
        }
        
        var isDirectory: Bool = false
        
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
    
    public func _fromURLToFileURL() -> URL {
        if self.isFileURL {
            return self
        }
        
        let pathComponents = self.pathComponents
        var fileURL = URL(fileURLWithPath: "/")
        
        for component in pathComponents {
            fileURL.appendPathComponent(component)
        }
        
        return fileURL
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
    
    public var _fileResourceIdentifierKey: NSObject? {
        get throws {
            let resourceValues = try self.resourceValues(forKeys: [.fileResourceIdentifierKey])
            
            if let fileID = resourceValues.fileResourceIdentifier {
                return try cast(fileID, to: NSObject.self)
            } else {
                return nil
            }
        }
    }

    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public var _preferredMIMEType: String? {
        if let pathExtension = self.pathExtension.isEmpty ? nil : self.pathExtension {
            if let uti = UTType(filenameExtension: pathExtension) {
                if let mimeType = uti.preferredMIMEType {
                    return mimeType
                }
            }
        }
        
        guard isFileURL else {
            guard !pathExtension.isEmpty else {
                return "application/octet-stream"
            }
            
            guard let mimeType = UTType(filenameExtension: pathExtension.lowercased())?.preferredMIMEType else {
                return "application/octet-stream"
            }
            
            return mimeType
        }
        
        do {
            let resourceValues = try self.resourceValues(forKeys: [.typeIdentifierKey])
            if let typeIdentifier = resourceValues.typeIdentifier {
                if let uti = UTType(typeIdentifier) {
                    if let mimeType = uti.preferredMIMEType {
                        return mimeType
                    }
                }
            }
        } catch {
            print("Error retrieving MIME type: \(error)")
        }
        
        return nil
    }

    public func _isValidFileURLCheckingIfExistsIfNecessary() -> Bool {
        if self.absoluteString.hasPrefix("file://") {
            return true
        } else if self.absoluteString.hasPrefix("/") {
            guard FileManager.default.fileExists(at: self) else {
                return false
            }
            
            return true
        } else {
            return false
        }
    }
    
    public func _asynchronouslyDownloadContentsOfFile() async throws -> Data {
        if self._isValidFileURLCheckingIfExistsIfNecessary() {
            if #available(iOS 15.0, macOS 12.0, *) {
                do {
                    return try Data(contentsOf: self)
                } catch {
                    throw error
                }
            } else {
                return try Data(contentsOf: self)
            }
        } else {
            if #available(iOS 15.0, macOS 12.0, *) {
                let (data, _) = try await URLSession.shared.data(from: self)
                
                return data
            } else {
                let data: Data = try await withCheckedThrowingContinuation { continuation in
                    let dataTask:  URLSessionDataTask = URLSession.shared.dataTask(with: self) {
                        data,
                        _,
                        error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data {
                            continuation.resume(returning: data)
                        } else {
                            continuation.resume(
                                throwing: NSError(
                                    domain: "URLDownloadError",
                                    code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]
                                )
                            )
                        }
                    }
                    
                    dataTask.resume()
                }
                
                return data
            }
        }
    }
}
