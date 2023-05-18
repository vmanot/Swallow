//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A value that can be compared against as an argument in an `NSPredicate`.
public protocol CocoaPredicateComparable {
    func toConstantValueForNSPredicate() -> NSCoding
}

// MARK: - Conformances

extension Bool: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        NSNumber(value: self)
    }
}

extension Decimal: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        self as NSNumber
    }
}

extension Double: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        NSNumber(value: self)
    }
}

extension Float: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        NSNumber(value: self)
    }
}

extension String: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        self as NSString
    }
}

extension Date: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        self as NSDate
    }
}

extension NSDate: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        self
    }
}

extension NSNumber: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        self
    }
}

extension NSString: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        self as NSString
    }
}

extension Int: CocoaPredicateComparable {
    public func toConstantValueForNSPredicate() -> NSCoding {
        NSNumber(value: self)
    }
}
