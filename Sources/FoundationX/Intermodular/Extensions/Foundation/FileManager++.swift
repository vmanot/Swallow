//
// Copyright (c) Vatsal Manot
//

import Foundation
import System
import Swallow
import UniformTypeIdentifiers

extension FileManager {
    /// Returns a Boolean value that indicates whether a file or directory exists at a specified URL.
    public func fileExists(
        at url: URL
    ) -> Bool {
        fileExists(atPath: url.path)
    }
    
    /// Returns a Boolean value that indicates whether a file or directory exists at a specified path.
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func fileExists(
        at path: FilePath
    ) -> Bool {
        fileExists(at: URL(_filePath: path)!)
    }
    
    /// Returns a Boolean value that indicates whether a file or directory exists at a specified path.
    public func fileOrDirectoryExists(
        at location: some URLRepresentable
    ) -> Bool {
        fileExists(at: location.url)
    }
    
    public func regularFileExists(
        at url: URL
    ) -> Bool {
        var isDirectory: ObjCBool = false
        
        let exists = self.fileExists(atPath: url.path, isDirectory: &isDirectory)
        
        return exists && !isDirectory.boolValue
    }
    
    public func fileIsDirectory(
        atPath path: String
    ) -> Bool {
        var isDirectory: ObjCBool = false
        
        let exists = fileExists(atPath: path, isDirectory: &isDirectory)
        
        return isDirectory.boolValue && exists
    }
    
    /// Returns a Boolean value that indicates whether a directory exists at a specified URL.
    public func directoryExists(
        at url: URL
    ) -> Bool {
        var isFolder: ObjCBool = false
        
        fileExists(atPath: url.path, isDirectory: &isFolder)
        
        if isFolder.boolValue {
            return true
        } else {
            return false
        }
    }
    
    /// Returns a Boolean value that indicates whether a directory exists at a specified path.
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func directoryExists(
        at path: FilePath
    ) -> Bool {
#if os(visionOS)
        return directoryExists(at: URL(filePath: path)!)
#else
        return directoryExists(at: URL(_filePath: path)!)
#endif
    }
    
    public func isDirectory<T: URLRepresentable>(
        at location: T
    ) -> Bool {
        let url = location.url
        var isDirectory = ObjCBool(false)
        
        guard fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return false
        }
        
        return isDirectory.boolValue
    }
    
    public func fileExistsAndIsReadable<T: URLRepresentable>(
        at location: T
    ) -> Bool {
        var url = location.url
        
        if isDirectory(at: url) && !url.path.hasSuffix("/") {
            url = URL(fileURLWithPath: url.path.appending("/"))
        }
        
        return isReadableFile(atPath: url.path)
    }
    
    public func isReadable<T: URLRepresentable>(
        at location: T
    ) -> Bool {
        fileExistsAndIsReadable(at: location)
    }
    
    public func isReadableAndWritable<T: URLRepresentable>(
        at location: T
    ) -> Bool {
        var url = location.url
        
        // Check if the file/directory exists
        if !fileExists(atPath: url.path) {
            // If it doesn't exist, recursively check parent directories
            while url.pathComponents.count > 1 {
                url.deleteLastPathComponent()
                if isReadableFile(atPath: url.path) && isWritableFile(atPath: url.path) {
                    return true
                }
            }
            return false
        }
        
        // If it exists, check its readability and writability
        if isDirectory(at: url) && !url.path.hasSuffix("/") {
            url = URL(fileURLWithPath: url.path.appending("/"))
        }
        
        return isReadableFile(atPath: url.path) && isWritableFile(atPath: url.path)
    }
    
    public func isReadableAndWritable<T: URLRepresentable>(
        atOrAncestorOf location: T
    ) -> Bool {
        let url = location.url._fromFileURLToURL()
        
        if isReadableAndWritable(at: url) {
            return true
        } else {
            let parentURL = url.resolvingSymlinksInPath().deletingLastPathComponent()
            
            guard parentURL != url, !parentURL.path.isEmpty else{
                return false
            }
            
            return isReadableAndWritable(atOrAncestorOf: parentURL)
        }
    }
        
    public func isSecurityScopedAccessible<T: URLRepresentable>(
        at location: T
    ) -> Bool {
        let url = location.url._fromFileURLToURL()
        
        if ((try? URL._SavedBookmarks.bookmarkedURL(for: location.url._fromFileURLToURL())) as URL?) != nil {
            return true
        }
        
        if isReadableAndWritable(at: url) {
            return true
        } else {
            let parentURL = url.deletingLastPathComponent()
            
            guard parentURL != url, !parentURL._isRootPath, !parentURL.path.isEmpty else {
                return false
            }
            
            return isSecurityScopedAccessible(at: parentURL)
        }
    }
}

extension FileManager {
    public func nearestAccessibleSecurityScopedAncestor<T: URLRepresentable>(
        for location: T
    ) -> URL? {
        let location: URL = location.url._fromFileURLToURL()
        
        if let result = try? URL._SavedBookmarks.bookmarkedURL(for: location) {
            return result
        } else if FileManager.default.fileOrDirectoryExists(at: location), let result = try? URL._SavedBookmarks.bookmark(location) {
            return result
        } else {
            /// FIXME:!!!! This looped infinitely when given a malformed URL created with a #fileID
            let parentURL: URL = location.resolvingSymlinksInPath().deletingLastPathComponent()
            
            guard !parentURL._isRootPath, parentURL != location, !parentURL._isRootPath, !parentURL.path.isEmpty else {
                return nil
            }
            
            guard let result: URL = nearestAccessibleSecurityScopedAncestor(for: parentURL) else {
                if FileManager.default.fileExists(at: parentURL) {
                    return parentURL
                } else {
                    runtimeIssue("Failed to find nearest accessible security scoped ancestor for \(location)")
                    
                    return nil
                }
            }
            
            return result
        }
    }
}

extension FileManager {
    public func suburls<T: URLRepresentable>(
        at location: T
    ) throws -> [T] {
        try contentsOfDirectory(atPath: location.url.path)
            .lazy
            .map({ location.url.appendingPathComponent($0) })
            .map({ try T(url: $0).unwrap() })
    }
    
    public func enumerateRecursively(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]? = nil,
        options mask: FileManager.DirectoryEnumerationOptions = [],
        body: (URL) throws -> Void
    ) throws {
        if !isDirectory(at: url) {
            return try body(url)
        }
        
        var errorEncountered: Error? = nil
        
        guard let enumerator = enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: mask,
            errorHandler: { url, error in
                errorEncountered = error
                
                return false
            }
        ) else {
            return
        }
        
        var urls: [URL] = []
        
        for case let fileURL as URL in enumerator {
            if let keys = keys {
                let _ = try fileURL.resourceValues(forKeys: .init(keys))
            }
            
            urls.append(fileURL)
        }
        
        try urls.forEach(body)
        
        if let error = errorEncountered {
            throw error
        }
    }
}

extension FileManager {
    public func createDirectoryIfNecessary(
        at url: URL,
        withIntermediateDirectories: Bool = false
    ) throws {
        guard !fileExists(at: url) else {
            return
        }
        
        try createDirectory(
            at: url,
            withIntermediateDirectories: withIntermediateDirectories,
            attributes: nil
        )
    }
    
    public func copyItemIfNecessary(
        at sourceURL: URL,
        to destinationURL: URL
    ) throws {
        guard !FileManager.default.fileExists(at: destinationURL) else {
            // FIXME: Validate via file hashes
            
            return
        }
        
        try copyItem(at: sourceURL, to: destinationURL)
    }
    
    public func withTemporaryCopy<Result>(
        of url: URL,
        perform body: (URL) throws -> Result
    ) throws -> Result {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        try copyItemIfNecessary(at: url, to: tempFileURL)
        
        do {
            let result = try body(tempFileURL)
            
            try removeItemIfNecessary(at: tempFileURL)
            
            return result
        } catch {
            try removeItemIfNecessary(at: tempFileURL)
            
            throw error
        }
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func removeItem(
        at path: FilePath
    ) throws {
        try removeItem(at: URL(_filePath: path).unwrap())
    }
    
    public func removeItemIfNecessary(
        at url: URL
    ) throws {
        guard fileExists(at: url) else {
            return
        }
        
        try removeItem(at: url)
    }
    
    public func removeItemIfNecessary(
        atPath path: String
    ) throws {
        guard fileExists(atPath: path) else {
            return
        }
        
        try removeItem(atPath: path)
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func removeItemIfNecessary(
        at url: FilePath
    ) throws {
        guard fileExists(at: url) else {
            return
        }
        
        try removeItem(at: url)
    }
}

extension FileManager {
    public func parentDirectory(
        for url: URL
    ) -> URL {
        let result = url.deletingLastPathComponent()
        
        assert(result.hasDirectoryPath)
        
        return result
    }
    
    public func createFile(
        at url: URL,
        contents: Data,
        attributes: [FileAttributeKey: Any]? = nil,
        withIntermediateDirectories: Bool = true
    ) throws {
        if withIntermediateDirectories {
            try createDirectoryIfNecessary(at: parentDirectory(for: url))
        }
        
        try contents.write(to: url, options: .atomic)
        
        if let attributes {
            try setAttributes(attributes, ofItemAtPath: url.path)
        }
    }
    
    public func contents(
        of url: URL
    ) throws -> Foundation.Data {
        do {
            return try contents(atPath: url.path).unwrap()
        } catch {
            if FileManager.default.fileExists(at: url) {
                let result = try url._accessingSecurityScopedResource {
                    try contents(atPath: url.path).unwrap()
                }
                
                return result
            }
            
            throw error
        }
    }
    
    public func contents(
        ofSecurityScopedResource url: URL
    ) throws -> Data {
        let contents: Data?
        
        do {
            contents = try url._accessingSecurityScopedResource {
                self.contents(atPath: url.path)
            }
        } catch let error as URL._SecurityScopedResourceAccessError {
            guard case .failedToAccessSecurityScopedResource = error else {
                throw error
            }
            
            guard let _contents = self.contents(atPath: url.path), !_contents.isEmpty else {
                throw error
            }
            
            contents = _contents
        }
        
        return try contents.unwrap()
    }
    
    public func contentsIfFileExists(
        of url: URL
    ) throws -> Data? {
        guard fileExists(at: url) else {
            return nil
        }
        
        return try contents(of: url)
    }
    
    public func contentsOfDirectory(
        at url: URL
    ) throws -> [URL] {
        func alternateResult() throws -> [URL] {
            return try contentsOfDirectory(atPath: url.path).map { path in
                let itemURL = url.appending(URL.PathComponent(rawValue: path, isDirectory: nil))
                
                assert(url.path != itemURL.path)
                
                return itemURL
            }
        }
        
        do {
            return try contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey])
        } catch(let error) {
            do {
                return try alternateResult()
            } catch(_) {
                throw error
            }
        }
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func contentsOfDirectory(
        at path: FilePath
    ) throws -> [URL] {
        try contentsOfDirectory(at: URL(_filePath: path).unwrap(), includingPropertiesForKeys: [])
    }
    
    public func setContents(
        of url: URL,
        to data: Data,
        createDirectoriesIfNecessary: Bool = true
    ) throws {
        if createDirectoriesIfNecessary {
            if directoryExists(at: url.deletingLastPathComponent()) {
                try data.write(to: url)
            } else {
                try createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
                
                try data.write(to: url)
            }
        } else {
            try data.write(to: url)
        }
    }
    
    public func isEmptyFile(at url: URL) -> Bool {
        guard let attributes: [FileAttributeKey : Any] = try? attributesOfItem(atPath: url.path) else {
            return false
        }
        
        guard let type: FileAttributeType = attributes[.type] as? FileAttributeType, type == .typeRegular else {
            return false
        }
        
        guard let size: Int64 = attributes[.size] as? Int64 else {
            return false
        }
        
        return size == 0
    }
}

extension FileManager {
    public func copyFolders(
        from sourceURLs: [URL],
        to destination: URLConvertible,
        replaceExisting: Bool
    ) throws {
        let destinationURL = destination.url
        
        if !fileExists(atPath: destinationURL.path) {
            try createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        } else {
            guard isDirectory(at: destinationURL) else {
                throw Never.Reason.illegal
            }
        }
        
        for sourceURL in sourceURLs {
            let folderName = sourceURL.lastPathComponent
            let destinationFolderURL = destinationURL.appendingPathComponent(folderName)
            
            if fileExists(atPath: destinationFolderURL.path) {
                if replaceExisting {
                    try removeItem(at: destinationFolderURL)
                } else {
                    throw Never.Reason.illegal
                }
            }
            
            try copyItem(at: sourceURL, to: destinationFolderURL)
        }
    }
}

extension FileManager {
    public var _practicallyIgnoredFilenames: [String] {
        return [
            ".DS_Store",
            ".localized",
            ".fseventsd",
            ".Spotlight-V100",
            ".TemporaryItems",
            ".Trashes"
        ]
    }
    
    /// Whether a directory is practically considered to be empty on Apple platforms.
    ///
    /// This filters out files like `.DS_Store` while testing for emptiness.
    public func isDirectoryPracticallyEmpty(
        at location: some URLRepresentable
    ) -> Bool {
        let location: URL = location.url
        
        guard let contents = try? contentsOfDirectory(at: location) else {
            if !fileExists(at: location) {
                return true
            }
            
            return false
        }
        
        let filteredContents = contents.filter { item in
            !_practicallyIgnoredFilenames.contains(item.lastPathComponent) && !item.lastPathComponent.hasPrefix("._")
        }
        
        return filteredContents.isEmpty
    }
}

extension FileManager {
    public func url(
        for directory: SearchPathDirectory,
        in domainMask: SearchPathDomainMask
    ) throws -> URL {
        enum ResolutionError: Error {
            case noURLFound
            case foundMultipleURLs
        }
        
        let urls = urls(for: directory, in: domainMask)
        
        guard let result = urls.first else {
            throw ResolutionError.noURLFound
        }
        
        guard urls.count == 1 else {
            throw ResolutionError.foundMultipleURLs
        }
        
        return result
    }
    
    public func documentsDirectoryURL(
        forUbiquityContainerIdentifier: String?
    ) throws -> URL? {
        guard let url = url(forUbiquityContainerIdentifier: forUbiquityContainerIdentifier)?.appendingPathComponent("Documents") else {
            return nil
        }
        
        guard !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) else {
            return url
        }
        
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        
        return url
    }
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension FileManager {
    public func firstAndOnly(
        where predicate: (URL) -> Bool,
        in directory: URL
    ) throws -> URL? {
        guard FileManager.default.fileExists(at: directory) else {
            return nil
        }
        
        return try self
            .contentsOfDirectory(at: directory)
            .firstAndOnly(where: predicate)
    }

    public func first(
        _ fileExtension: UTType,
        in directory: URL
    ) throws -> URL? {
        try self
            .contentsOfDirectory(at: directory)
            .first(where: { $0._fileExtension.map({ UTType(filenameExtension: $0) }) == fileExtension })
    }
    
    public func firstAndOnly(
        _ fileExtension: UTType,
        in directory: URL
    ) throws -> URL? {
        guard FileManager.default.fileExists(at: directory) else {
            return nil
        }
        
        return try self
            .contentsOfDirectory(at: directory)
            .first(where: { $0._fileExtension.map({ UTType(filenameExtension: $0) }) == fileExtension })
    }
    
    public func items<T: URLInitiable>(
        ofType type: T.Type,
        at url: URL
    ) throws -> [T] {
        try contentsOfDirectory(at: url).compactMap({ (item: URL) in try? T.init(url: item) })
    }
}
#endif
