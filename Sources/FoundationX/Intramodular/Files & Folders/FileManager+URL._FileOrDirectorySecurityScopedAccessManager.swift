//
// Copyright (c) Vatsal Manot
//

import Swallow

extension FileManager {
    public func requestingUserGrantedAccessIfPossible<T>(
        for location: some URLRepresentable,
        scope: URL._FileOrDirectorySecurityScopedAccessManager.PreferredScope = .automatic,
        perform operation: (URL) throws -> T
    ) throws -> T {
        if Thread.isMainThread {
            return try MainActor.unsafeAssumeIsolated {
                try self.withUserGrantedAccess(to: location, scope: scope, perform: operation)
            }
        } else {
            return try operation(location.url)
        }
    }
    
    @MainActor
    public func requestingUserGrantedAccessIfPossible<T>(
        for location: some URLRepresentable,
        scope: URL._FileOrDirectorySecurityScopedAccessManager.PreferredScope = .automatic,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
        let result: T = try await self.withUserGrantedAccess(to: location, scope: scope, perform: operation)
        
        return result
    }
}

extension FileManager {
    @MainActor
    public func withUserGrantedAccess<T>(
        to location: some URLRepresentable,
        scope: URL._FileOrDirectorySecurityScopedAccessManager.PreferredScope = .automatic,
        perform operation: (URL) throws -> T
    ) throws -> T {
        guard !FileManager.default.isReadableAndWritable(at: location) else {
            return try operation(location.url)
        }
        
        let url: URL = location.url
        
        switch scope {
            case .automatic:
                return try _withUserGrantedAccess(to: url, perform: operation)
            case .directory:
                if !url._isKnownOrIndicatedToBeFileDirectory {
                    return try _withUserGrantedAccess(toFile: url, perform: operation)
                } else {
                    return try _withUserGrantedAccess(to: url, perform: operation)
                }
        }
    }
    
    @MainActor
    public func withUserGrantedAccess<T>(
        to location: some URLRepresentable,
        scope: URL._FileOrDirectorySecurityScopedAccessManager.PreferredScope = .automatic,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
        guard !FileManager.default.isReadableAndWritable(at: location) else {
            return try await operation(location.url)
        }

        let url: URL = location.url
        
        switch scope {
            case .automatic:
                return try await _withUserGrantedAccess(to: url, perform: operation)
            case .directory:
                if !url._isKnownOrIndicatedToBeFileDirectory {
                    return try await _withUserGrantedAccess(toFile: url, perform: operation)
                } else {
                    return try await _withUserGrantedAccess(to: url, perform: operation)
                }
        }
    }
    
    @MainActor
    private func _withUserGrantedAccess<T>(
        toFile url: URL,
        perform operation: (URL) throws -> T
    ) throws -> T {
        if let result = try Self._withCachedSecurityScopedAccessibleResourceURLIfExists(for: url, perform: operation) {
            return result
        }

        let directoryURL: URL = url._immediateFileDirectory
        let lastPathComponent: String = url.lastPathComponent
        
        return try _withUserGrantedAccess(to: directoryURL) { directoryURL in
            let accessibleURL = directoryURL.appendingPathComponent(lastPathComponent, isDirectory: false)
            
            return try operation(accessibleURL)
        }
    }
    
    @MainActor
    private func _withUserGrantedAccess<T>(
        toFile url: URL,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
        if let result = try await Self._withCachedSecurityScopedAccessibleResourceURLIfExists(for: url, perform: operation) {
            return result
        }

        let directoryURL: URL = url._immediateFileDirectory
        let lastPathComponent: String = url.lastPathComponent
        
        return try await _withUserGrantedAccess(to: directoryURL) { directoryURL in
            let accessibleURL = directoryURL.appendingPathComponent(lastPathComponent, isDirectory: false)
            
            return try await operation(accessibleURL)
        }
    }
    
    @MainActor
    private func _withUserGrantedAccess<T>(
        to location: any URLRepresentable,
        perform operation: (URL) throws -> T
    ) throws -> T {
        if let result: T = try? Self._withCachedSecurityScopedAccessibleResourceURLIfExists(for: location, perform: operation) {
            return result
        }

        let url = try URL._FileOrDirectorySecurityScopedAccessManager.requestAccess(to: location.url)
        
        return try url._accessingSecurityScopedResource { () -> T in
            do {
                if FileManager.default.fileExists(at: url) {
                    _ = try URL._SavedBookmarks.bookmark(url)
                }
            } catch {
                runtimeIssue(error)
            }

            return try operation(url)
        }
    }
    
    @MainActor
    private func _withUserGrantedAccess<T>(
        to location: any URLRepresentable,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
        if let result: T = try? await Self._withCachedSecurityScopedAccessibleResourceURLIfExists(for: location, perform: operation) {
            return result
        }
        
        let url: URL = try URL._FileOrDirectorySecurityScopedAccessManager.requestAccess(to: location.url)
        
        return try await url._accessingSecurityScopedResource { () -> T in
            do {
                _ = try URL._SavedBookmarks.bookmark(url)
            } catch {
                runtimeIssue(error)
            }

            return try await operation(url)
        }
    }
    
    private static func _withCachedSecurityScopedAccessibleResourceURLIfExists<T>(
        for location: any URLRepresentable,
        perform operation: (URL) throws -> T
    ) throws -> T? {
        guard let url: URL = try? URL._SavedBookmarks.bookmarkedURL(for: location) else {
            return nil
        }
        
        let result = try url._accessingSecurityScopedResource({
            return Result(catching: { try operation(url) })
        })
        
        return try result.get()
    }
    
    private static func _withCachedSecurityScopedAccessibleResourceURLIfExists<T>(
        for location: any URLRepresentable,
        perform operation: (URL) async throws -> T
    ) async throws -> T? {
        guard let url: URL = try? URL._SavedBookmarks.bookmarkedURL(for: location) else {
            return nil
        }
        
        let result = try await url._accessingSecurityScopedResource({
            return await Result(catching: { try await operation(url) })
        })
        
        return try result.get()
    }
}
