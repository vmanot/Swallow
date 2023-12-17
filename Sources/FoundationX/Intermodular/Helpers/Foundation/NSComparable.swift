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

extension NSComparableReferenceConvertee where Self == ReferenceConvertibleType.ReferenceType {
    public func compare(_ other: Self) -> ComparisonResult {
        return compare(other as! ReferenceConvertibleType)
    }
    
    public func compare(_ other: ReferenceConvertibleType) -> ComparisonResult {
        return compare(other as! Self)
    }
}
