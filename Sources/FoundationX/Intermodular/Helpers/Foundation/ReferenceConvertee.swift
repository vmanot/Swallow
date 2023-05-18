//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol ReferenceConvertee {
    associatedtype ReferenceConvertibleType: ReferenceConvertible

    init(_: ReferenceConvertibleType)

    func toReferenceConvertible() -> ReferenceConvertibleType
}

extension ReferenceConvertee where ReferenceConvertibleType.ReferenceType == Self {
    public init(_ referenceWrapped: ReferenceConvertibleType) {
        self = try! cast(referenceWrapped)
    }

    public func toReferenceConvertible() -> ReferenceConvertibleType {
        return try! cast(self)
    }
}
