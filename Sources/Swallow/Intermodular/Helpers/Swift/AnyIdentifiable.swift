//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyIdentifiable<ID>: Identifiable {
    public let base: any Identifiable<ID>
    
    public var id: AnyHashable {
        base.id.erasedAsAnyHashable
    }
    
    public init(erasing base: any Identifiable<ID>) {
        self.base = base
    }
}
