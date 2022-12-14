//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol Identifier: Hashable {
    
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
