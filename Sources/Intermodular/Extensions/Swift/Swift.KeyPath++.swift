//
// Copyright (c) Vatsal Manot
//

import Swift

extension WritableKeyPath where Root: AnyObject {
    open func referenceSetter(for root: Root) -> ((Value) -> ()) {
        return hack { { var root = root; root[keyPath: self] = $0 } }
    }
}

extension ReferenceWritableKeyPath  {
    open func setter(for root: Root) -> ((Value) -> ()) {
        return { root[keyPath: self] = $0 }
    }
}
