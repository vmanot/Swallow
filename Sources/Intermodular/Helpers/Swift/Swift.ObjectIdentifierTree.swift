//
// Copyright (c) Vatsal Manot
//

import Swift

public enum ObjectIdentifierTree: Hashable {
    case structure(ObjectIdentifier, children: [ObjectIdentifierTree])
    case object(ObjectIdentifier, children: [ObjectIdentifierTree])

    indirect case wrapper(ObjectIdentifier, over: ObjectIdentifierTree)

    public init(object: AnyObject, children: [ObjectIdentifierTree] = []) {
        self = .object(.init(object), children: children)
    }

    public func wrapped(by object: AnyObject) -> ObjectIdentifierTree {
        return .wrapper(.init(object), over: self)
    }

    public func wrapped(by type: Any.Type) -> ObjectIdentifierTree {
        return .wrapper(.init(type), over: self)
    }
}

extension ObjectIdentifierTree: ApproximatelyEquatable {
    public var origin: ObjectIdentifierTree {
        if case let .wrapper(_, unwrapped) = self {
            return unwrapped.origin
        } else {
            return self
        }
    }

    public static func ~= (lhs: ObjectIdentifierTree, rhs: ObjectIdentifierTree) -> Bool {
        if lhs == rhs {
            return true
        } else if case let .wrapper(_, lhsUnwrapped) = lhs {
            return lhsUnwrapped == rhs || lhsUnwrapped ~= lhs
        } else {
            return false
        }
    }
}
