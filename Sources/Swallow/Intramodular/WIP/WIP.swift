//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _IsAnyObjectDisclosing {
    associatedtype _IsAnyObject: _StaticBoolean
}

extension _IsAnyObjectDisclosing {
    public typealias _IsAnyObject = Bool.False
}

extension _IsAnyObjectDisclosing where Self: AnyObject {
    public typealias _IsAnyObject = Bool.True
}
