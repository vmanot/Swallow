//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Decimal: Swallow.BooleanInitiable {
    @inlinable
    public init(_ value: Bool) {
        self.init(value as NSNumber)
    }
    
    @inlinable
    public init(_ value: DarwinBoolean) {
        self.init(Bool(value))
    }
    
    @inlinable
    public init(_ value: ObjCBool) {
        self.init(Bool(value))
    }
}
