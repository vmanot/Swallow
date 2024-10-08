//
// Copyright (c) Vatsal Manot
//

import Swallow
import System

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
    public var _filePath: String {
        let url = resolvingSymlinksInPath()
        var result: String
        
        if let absolutePath = try? url
            .resourceValues(forKeys: [.canonicalPathKey])
            .canonicalPath {
            result = absolutePath
        } else {
            result = path
        }
        
        while result.starts(with: "//") {
            result = String(result.dropFirst())
        }
        
        return result
    }
    
    public var _isCanonicallyHiddenFile: Bool {
        _fileNameWithoutExtension.hasPrefix(".")
    }
    
    /// Checks if the URL is a relative path.
    public var _isRelativeFilePath: Bool {
        // A URL is considered relative if it does not have a scheme and is not absolute.
        return self.scheme == nil && !self.absoluteString.hasPrefix("/")
    }
    
    /// Checks if the URL or any part of it is a symbolic link.
    public var _containsSymbolicLink: Bool {
        var currentPath = self.standardized
        
        while currentPath.path != "/" {
            do {
                let resourceValues = try currentPath.resourceValues(forKeys: [.isSymbolicLinkKey])
                
                if resourceValues.isSymbolicLink == true {
                    return true
                }
                
                currentPath.deleteLastPathComponent()
            } catch {
                break
            }
        }
        
        return false
    }
    
    public var _fileNameWithoutExtension: String {
        self.deletingPathExtension().lastPathComponent
    }
    
    public var _fileNameWithExtension: String? {
        lastPathComponent
    }
    
    public var _fileExtension: String? {
        guard !pathExtension.isEmpty else {
            return nil
        }
        
        return pathExtension
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
    
    /// Drop the fucking "/" at the end.
    public var _standardizedFilePath: String {
        path.dropSuffixIfPresent("/")
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
        
        return URL(string: resolvingSymlinksInPath().path)!.standardizedFileURL
    }
    
    public func _fromURLToFileURL() -> URL {
        guard !self.isFileURL else {
            let result = standardizedFileURL
            
            assert(!result.path.hasPrefix("//"))
            
            return result
        }
        
        let pathComponents = self.pathComponents
        var fileURL = URL(fileURLWithPath: "/")
        
        var lastComponent: String?
        
        for var component in pathComponents {
            if component == "/" && lastComponent == "/" {
                continue
            }
            
            if component == "//" {
                component = "/"
            }
            
            fileURL.appendPathComponent(component)
            
            lastComponent = component
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

extension URL {
    public func _setIsPackageKey(_ value: Bool = true) throws {
        var isDirectory: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) else {
            return
        }
        
        if isDirectory.boolValue {
            try (self as NSURL).setResourceValue(value, forKey: .isPackageKey)
        }
    }
}
