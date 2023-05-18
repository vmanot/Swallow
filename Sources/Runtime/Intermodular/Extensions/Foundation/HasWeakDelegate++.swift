//
// Copyright (c) Vatsal Manot
//

import Foundation
import FoundationX
import Swallow

private let strongDelegateKey = ObjCAssociationKey<Any>()

extension HasWeakDelegate where Self: ObjCObject {
    public func setStrongDelegate(_ delegate: Delegate) {
        self[strongDelegateKey] = delegate
        self._setDelegate(delegate)
    }

    public func setStrongDelegateIfNecessary(_ delegate: @autoclosure () -> Delegate) {
        if self[strongDelegateKey] == nil {
            setStrongDelegate(delegate())
        }
    }

    public func removeStrongDelegate() {
        self[strongDelegateKey] = nil
        self._setDelegate(nil)
    }
}
