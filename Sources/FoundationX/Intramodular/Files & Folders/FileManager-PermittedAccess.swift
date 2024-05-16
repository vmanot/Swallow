//
// Copyright (c) Vatsal Manot
//

import Swallow

extension FileManager {    
    @MainActor(unsafe)
    public func withUserGrantedAccess<T>(
        to location: some URLRepresentable,
        scope: URL._FileOrDirectorySecurityScopedAccessManager.PreferredScope = .automatic,
        perform operation: (URL) throws -> T
    ) throws -> T {
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
    
    @MainActor(unsafe)
    public func withUserGrantedAccess<T>(
        to location: some URLRepresentable,
        scope: URL._FileOrDirectorySecurityScopedAccessManager.PreferredScope = .automatic,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
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
        if let url: URL = try? URL._BookmarkCache.cachedURL(for: location) {
            do {
                let result = try url._accessingSecurityScopedResource({
                    return Result(catching: { try operation(url) })
                })
                
                return try result.get()
            } catch {
                runtimeIssue(error)
            }
        } 
        
        let url = try URL._FileOrDirectorySecurityScopedAccessManager.requestAccess(to: location.url)
        
        return try url._accessingSecurityScopedResource {
            try operation(url)
        }
    }
    
    @MainActor
    private func _withUserGrantedAccess<T>(
        to location: any URLRepresentable,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
        if let url: URL = try? URL._BookmarkCache.cachedURL(for: location) {
            do {
                let result = try await url._accessingSecurityScopedResource({
                    return await Result(catching: { try await operation(url) })
                })
                
                return try result.get()
            } catch {
                runtimeIssue(error)
            }
        }
        
        let url: URL = try await MainActor.run {
            try URL._FileOrDirectorySecurityScopedAccessManager.requestAccess(to: location.url)
        }
        
        return try await url._accessingSecurityScopedResource {
            try await operation(url)
        }
    }
}
