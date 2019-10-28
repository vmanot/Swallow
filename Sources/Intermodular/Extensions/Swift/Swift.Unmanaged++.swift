//
// Copyright (c) Vatsal Manot
//

import Swift

extension Unmanaged {
    @inlinable
    public static func unretain(_ instance: Instance) {
        _ = unretained(instance)
    }

    @discardableResult @inlinable
    public static func unretained(_ instance: Instance) -> Unmanaged {
        return passUnretained(instance)
    }

    @inlinable
    public static func retain(_ instance: Instance) {
        _ = retaining(instance)
    }

    @discardableResult @inlinable
    public static func retaining(_ instance: Instance) -> Unmanaged {
        return passUnretained(instance).retain()
    }

    @inlinable
    public static func release(_ instance: Instance) {
        _ = releasing(instance)
    }

    @discardableResult @inlinable
    public static func releasing(_ instance: Instance) -> Unmanaged {
        let result = passUnretained(instance)

        result.release()

        return result
    }

    @inlinable
    public static func autorelease(_ instance: Instance) {
        _ = autoreleasing(instance)
    }

    @discardableResult @inlinable
    public static func autoreleasing(_ instance: Instance) -> Unmanaged {
        return passUnretained(instance).autorelease()
    }
}
