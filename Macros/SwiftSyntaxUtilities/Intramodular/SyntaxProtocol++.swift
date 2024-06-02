//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension SyntaxProtocol {
    public func modifying<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        _ modify: (inout T) throws -> Void
    ) rethrows -> Self {
        var result = self
        var value = self[keyPath: keyPath]
        
        try modify(&value)
        
        result[keyPath: keyPath] = value
        
        return result
    }
    
    public func map<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        _ transform: (T) throws -> T
    ) rethrows -> Self {
        var result = self
        
        result[keyPath: keyPath] = try transform(self[keyPath: keyPath])
        
        return result
    }
}
