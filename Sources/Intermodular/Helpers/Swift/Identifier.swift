//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _opaque_Identifier: _opaque_Hashable {
    
}

public protocol Identifier: _opaque_Identifier, Hashable {
    
}

public protocol IdentifierGenerator {
    associatedtype Identifier: Swallow.Identifier
    
    mutating func next() -> Identifier
}

// MARK: - Conformances -

extension AnyHashable: Identifier {
    
}

extension ObjectIdentifier: Identifier {
    
}

extension UUID: Identifier {
    
}
