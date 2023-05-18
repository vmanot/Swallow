//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol NSComparable: Comparable {
    func compare(_ other: Self) -> ComparisonResult
}

public protocol NSComparableReferenceConvertee: ReferenceConvertee {
    func compare(_ other: ReferenceConvertibleType) -> ComparisonResult
}

// MARK: - Implementation

extension NSComparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) == .orderedAscending
    }
    
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) != .orderedDescending
    }
    
    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) == .orderedDescending
    }
    
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) != .orderedAscending
    }
}

extension NSComparableReferenceConvertee where Self == ReferenceConvertibleType.ReferenceType {
    public func compare(_ other: Self) -> ComparisonResult {
        return compare(other as! ReferenceConvertibleType)
    }
    
    public func compare(_ other: ReferenceConvertibleType) -> ComparisonResult {
        return compare(other as! Self)
    }
}
