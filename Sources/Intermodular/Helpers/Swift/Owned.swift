//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Owned: AnyProtocol {
    associatedtype Owner

    var owner: Owner { get }
}

public protocol OwnerWrapper: Owned {
    init(owner: Owner)
}

public protocol MutableOwnerWrapper: OwnerWrapper {
    var owner: Owner { get set }
}
