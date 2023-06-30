//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyIdentifiable: Identifiable {
    public let base: any Identifiable
    
    public var id: AnyHashable {
        base.id.erasedAsAnyHashable
    }
    
    public init(erasing base: any Identifiable) {
        self.base = base
    }
}
