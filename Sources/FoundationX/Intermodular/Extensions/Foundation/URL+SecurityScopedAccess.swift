//
// Copyright (c) Vatsal Manot
//

import Swallow

extension URL {
    @frozen
    public enum _SecurityScopedResourceAccessError: Error {
        case failedToAccessSecurityScopedResource(for: URL)
    }
    
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
