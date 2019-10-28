//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Comparable2 = opaque_Comparable & Comparable

public protocol opaque_Comparable: opaque_Equatable {
    func opaque_Comparable_is(lessThan _: Any) -> Bool?
    func opaque_Comparable_is(lessThanOrEqualTo _: Any) -> Bool?
    func opaque_Comparable_is(moreThan _: Any) -> Bool?
    func opaque_Comparable_is(moreThanOrEqualTo _: Any) -> Bool?
}

extension opaque_Comparable where Self: Comparable {
    public func opaque_Comparable_is(lessThan other: Any) -> Bool? {
        return (-?>other).map({ self < $0 })
    }
    
    public func opaque_Comparable_is(lessThanOrEqualTo other: Any) -> Bool? {
        return (-?>other).map({ self <= $0 })
    }
    
    public func opaque_Comparable_is(moreThan other: Any) -> Bool? {
        return (-?>other).map({ self > $0 })
    }
    
    public func opaque_Comparable_is(moreThanOrEqualTo other: Any) -> Bool? {
        return (-?>other).map({ self >= $0 })
    }
}
