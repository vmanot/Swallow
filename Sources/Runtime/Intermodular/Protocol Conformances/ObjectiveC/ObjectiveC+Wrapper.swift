//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCBool: MutableWrapper {
    @inlinable
    public var value: Bool {
        get {
            return .init(self)
        } set {
            self = .init(newValue)
        }
    }
}

extension Selector: MutableWrapper {
    @inlinable
    public var value: String {
        get {
            return .init(_sel: self)
        } set {
            self = .init(newValue)
        }
    }
}
