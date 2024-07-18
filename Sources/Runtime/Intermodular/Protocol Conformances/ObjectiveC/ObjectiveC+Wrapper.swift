//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCBool: Swallow.MutableWrapper {
    @inlinable
    public var value: Bool {
        get {
            return .init(self)
        } set {
            self = .init(newValue)
        }
    }
}

extension Selector: Swallow.MutableWrapper {
    @inlinable
    public var value: String {
        get {
            return .init(_sel: self)
        } set {
            self = .init(newValue)
        }
    }
}
