//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol MetatypeRepresentable {
    init?(metatype: Any.Type)
    
    func toMetatype() -> Any.Type
}

// MARK: - Implementation

extension MetatypeRepresentable {
    public init?(metadata: TypeMetadata) {
        self.init(metatype: metadata.base)
    }
    
    public func toTypeMetadata() -> TypeMetadata {
        return .init(toMetatype())
    }
}
