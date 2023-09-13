//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public protocol _IsAnyObjectDisclosing {
    associatedtype _IsAnyObject: _StaticBoolean
}

@_spi(Internal)
extension _IsAnyObjectDisclosing {
    public typealias _IsAnyObject = Bool.False
}

@_spi(Internal)
extension _IsAnyObjectDisclosing where Self: AnyObject {
    public typealias _IsAnyObject = Bool.True
}
