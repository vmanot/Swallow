//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Comparable2 = _opaque_Comparable & Comparable

public protocol _opaque_Comparable: _opaque_Equatable {
    func _opaque_Comparable_is(lessThan _: Any) -> Bool?
    func _opaque_Comparable_is(lessThanOrEqualTo _: Any) -> Bool?
    func _opaque_Comparable_is(moreThan _: Any) -> Bool?
    func _opaque_Comparable_is(moreThanOrEqualTo _: Any) -> Bool?
}

extension _opaque_Comparable where Self: Comparable {
    public func _opaque_Comparable_is(lessThan other: Any) -> Bool? {
        return (-?>other).map({ self < $0 })
    }
    
    public func _opaque_Comparable_is(lessThanOrEqualTo other: Any) -> Bool? {
        return (-?>other).map({ self <= $0 })
    }
    
    public func _opaque_Comparable_is(moreThan other: Any) -> Bool? {
        return (-?>other).map({ self > $0 })
    }
    
    public func _opaque_Comparable_is(moreThanOrEqualTo other: Any) -> Bool? {
        return (-?>other).map({ self >= $0 })
    }
}
