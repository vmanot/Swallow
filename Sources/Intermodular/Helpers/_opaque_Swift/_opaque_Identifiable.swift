//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_Identifiable: AnyProtocol {
    var _opaque_id: AnyHashable { get }
}

extension _opaque_Identifiable where Self: Identifiable {
    public var _opaque_id: AnyHashable {
        AnyHashable(id)
    }
}
