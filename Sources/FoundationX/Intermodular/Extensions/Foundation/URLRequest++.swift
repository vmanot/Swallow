//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension URLRequest {
    @inlinable
    public func withMutableURL(
        _ modify: (inout URL) throws -> Void
    ) throws -> Self {
        var url = try self.url.unwrap()
        
        try modify(&url)
        
        var result = self
        
        result.url = url
        
        return result
    }
}
