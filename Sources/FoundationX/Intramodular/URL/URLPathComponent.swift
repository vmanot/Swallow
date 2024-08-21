//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension URL {
    /// A file path component suitable for a base URL to append.
    public struct PathComponent: CustomStringConvertible, ExpressibleByStringLiteral, Codable, Hashable, Sendable {
        public let rawValue: String
        public let isDirectory: Bool?
        
        public var description: String {
            rawValue
        }
        
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
    
    public struct RelativePath: Codable, CustomStringConvertible, Hashable, Sendable {
        public let components: [URL.PathComponent]
        
        public var description: String {
            "./" + components.map(\.rawValue).joined(separator: "/")
        }
        
        public var path: String {
            components.map(\.rawValue).joined(separator: "/")
        }
        
        public init(components: [URL.PathComponent]) {
            self.components = components
        }
        
        public func appending(_ component: URL.PathComponent) -> Self {
            .init(components: components.appending(component))
        }
        
        public func appending(_ component: String) -> Self {
            appending(URL.PathComponent(stringLiteral: component))
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
        guard baseURL.scheme != nil, self.scheme != nil else {
            throw URLError(.badURL)
        }
        
        guard baseURL.host == self.host else {
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

extension FileManager {
    enum EnumerateRelativePathsError: Error {
        case invalidDirectoryURL
        case enumerationFailed
    }
    
    public func enumerateRelativePaths(
        forDirectory directoryURL: URL
    ) throws -> [URL.RelativePath] {
        guard directoryURL.isFileURL else {
            throw EnumerateRelativePathsError.invalidDirectoryURL
        }
        
        var isDirectory: ObjCBool = false
        
        guard fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) && isDirectory.boolValue else {
            throw EnumerateRelativePathsError.invalidDirectoryURL
        }
        
        guard let enumerator = self.enumerator(atPath: directoryURL.path) else {
            throw EnumerateRelativePathsError.enumerationFailed
        }
        
        var relativePaths: [URL.RelativePath] = []
        
        for case let relativePath as String in enumerator {
            let fullPath = directoryURL.appendingPathComponent(relativePath)
            
            let pathComponent = URL.PathComponent(
                rawValue: relativePath,
                isDirectory: directoryExists(at: fullPath)
            )
            
            relativePaths.append(URL.RelativePath(components: [pathComponent]))
        }
        
        return relativePaths
    }
    
    public func nearestAncestor(
        for location: URL,
        where predicate: (URL) -> Bool
    ) -> (ancestor: URL, path: URL.RelativePath)? {
        var currentURL = location
        var pathComponents: [String] = []
        
        while currentURL.path != "/" {
            if predicate(currentURL) {
                let relativePath = URL.RelativePath(components: pathComponents.map({ URL.PathComponent(rawValue: $0) }))
                
                return (ancestor: currentURL, path: relativePath)
            }
            
            let currentLastPathComponent = currentURL.lastPathComponent
            
            currentURL = currentURL.deletingLastPathComponent()
            
            pathComponents.insert(currentLastPathComponent, at: 0)
        }
        
        return nil
    }
}

extension FileWrapper {
    enum EnumerateFileWrappersError: Error {
        case invalidFileWrapper
    }
    
    public func enumerateFileWrappers() throws -> [URL.RelativePath: FileWrapper] {
        guard isDirectory else {
            throw EnumerateFileWrappersError.invalidFileWrapper
        }
        
        return enumerateFileWrappersRecursively(base: .init(components: [])) ?? [:]
    }
    
    private func enumerateFileWrappersRecursively(
        base: URL.RelativePath
    ) -> [URL.RelativePath: FileWrapper]? {
        var results: [URL.RelativePath: FileWrapper] = [:]
        
        results.append((base, self))

        guard isDirectory else {
            return results
        }
        
        for (fileName, childWrapper) in fileWrappers ?? [:] {
            let childPath: URL.RelativePath = base.appending(fileName)
            
            results.append((childPath, childWrapper))

            if let subResults = childWrapper.enumerateFileWrappersRecursively(base: childPath) {
                results.append(contentsOf: subResults)
            }
        }
        
        return results
    }
}
