//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSRange {        
    @inlinable
    public init<R: RangeExpression>(
        _ range: R,
        lowerBound: Int = 0,
        upperBound: Int
    ) where R.Bound: FixedWidthInteger {
        self.init(range.relative(to: R.Bound(lowerBound)..<R.Bound(upperBound)))
    }
    
    @inlinable
    public func contains(_ other: NSRange) -> Bool {
        return true
            && lowerBound <= other.lowerBound
            && upperBound >= other.upperBound
    }
}

extension NSRange {
    public init?(utf8Range: Range<String.Index>, in string: String) {
        let utf8 = string.utf8
        
        guard let lowerBound = utf8Range.lowerBound.samePosition(in: utf8), let upperBound = utf8Range.upperBound.samePosition(in: utf8) else {
            return nil
        }
        
        self.init(
            location: utf8.distance(from: utf8.startIndex, to: lowerBound),
            length: utf8.distance(from: lowerBound, to: upperBound)
        )
    }
    
    public init?(utf16Range: Range<String.Index>, in string: String) {
        let utf16 = string.utf16
        
        guard let lowerBound = utf16Range.lowerBound.samePosition(in: utf16), let upperBound = utf16Range.upperBound.samePosition(in: utf16) else {
            return nil
        }
        
        self.init(
            location: utf16.distance(from: utf16.startIndex, to: lowerBound),
            length: utf16.distance(from: lowerBound, to: upperBound)
        )
    }
}
