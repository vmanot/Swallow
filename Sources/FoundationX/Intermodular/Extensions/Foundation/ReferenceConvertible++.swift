//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension ReferenceConvertible {
    @inlinable
    public func toReferenceType() -> ReferenceType {
        return try! cast(self)
    }
}
