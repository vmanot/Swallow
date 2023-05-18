//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TypeMetadata: TypeMetadataType {
    public let base: Any.Type
    
    public init(_ base: Any.Type) {
        self.base = base
    }
}

// MARK: - Conformances

extension TypeMetadata: MetatypeRepresentable {
    public init(metatype: Any.Type) {
        self.init(metatype)
    }
    
    public func toMetatype() -> Any.Type {
        return base
    }
}

/// Returns whether a given value is a type of a type (a metatype).
///
/// ```swift
/// isMetatype(Int.self) // false
/// isMetatype(Int.Type.self) // true
/// ```
public func _isMetatypeKind<T>(_ x: T) -> Bool {
    guard let type = x as? Any.Type else {
        return false
    }
    
    let metadata = TypeMetadata(type)
    
    switch metadata.kind {
        case .metatype, .existentialMetatype:
            return true
        default:
            return false
    }
}
