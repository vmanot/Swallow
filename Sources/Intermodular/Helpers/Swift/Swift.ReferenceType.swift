//
// Copyright (c) Vatsal Manot
//

import Swift

/// A reference type (or a wrapper of one).
public protocol ReferenceType: AnyProtocol {
    var objectIdentifierTree: ObjectIdentifierTree { get }
    var isUniquelyReferenced: Bool { mutating get }
}

// MARK: - Implementation -

extension ReferenceType where Self: AnyObject {
    public var objectIdentifierTree: ObjectIdentifierTree {
        return .init(object: self)
    }

    public var isUniquelyReferenced: Bool {
        mutating get {
            return isKnownUniquelyReferenced(&self)
        }
    }
}

extension ReferenceType where Self: OwnerWrapper, Self.Owner: ReferenceType {
    public var objectIdentifierTree: ObjectIdentifierTree {
        return owner
            .objectIdentifierTree
            .wrapped(by: type(of: self))
    }
}

extension ReferenceType where Self: MutableOwnerWrapper, Self.Owner: ReferenceType {
    public var isUniquelyReferenced: Bool {
        mutating get {
            return owner.isUniquelyReferenced
        }
    }
}
