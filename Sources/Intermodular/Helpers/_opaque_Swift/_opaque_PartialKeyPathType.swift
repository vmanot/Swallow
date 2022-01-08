//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _opaque_PartialKeyPathType {
    static var _opaque_RootType: Any.Type { get }
}

// MARK: - Implementation -

extension PartialKeyPath: _opaque_PartialKeyPathType {
    public static var _opaque_RootType: Any.Type {
        Root.self
    }
}
