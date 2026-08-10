//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

/// A type that logs its activities.
public protocol Logging {
    static var logger: PassthroughLogger { get }

    var logger: PassthroughLogger { get }
}

private final class _LoggerObjCAssociationKey: @unchecked Sendable {
    static let shared = _LoggerObjCAssociationKey()

    var pointer: UnsafeRawPointer {
        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
}

extension Logging {
    public static var logger: PassthroughLogger {
        PassthroughLogger(source: .type(self))
    }

    public var logger: PassthroughLogger {
        if swift_isClassType(type(of: self)) {
            let object = self as! any Logging & AnyObject

            return object._defaultLogger
        } else {
            return PassthroughLogger(source: .something(self))
        }
    }
}

extension Logging where Self: AnyObject {
    fileprivate var _defaultLogger: PassthroughLogger {
        let associationKey = _LoggerObjCAssociationKey.shared.pointer

        if let result = objc_getAssociatedObject(self, associationKey) as? PassthroughLogger {
            return result
        }

        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        if let result = objc_getAssociatedObject(self, associationKey) as? PassthroughLogger {
            return result
        }

        let result = PassthroughLogger(source: .object(self))

        objc_setAssociatedObject(self, associationKey, result, .OBJC_ASSOCIATION_RETAIN)

        return result
    }
}
