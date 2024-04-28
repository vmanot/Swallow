//
// Copyright (c) Vatsal Manot
//

import Swift

extension CountableRange {
    public func allNonEmptySubRanges() -> [CountableRange<Index>] {        
        guard count != 0 else {
            return []
        }

        var result = Array<CountableRange<Index>>()
        
        result.reserveCapacity(numericCast(count * count.advanced(by: 1) / 2))
        
        for element in self {
            var bound = element
            
            while bound != upperBound {
                bound = bound.advanced(by: 1)
                result.append(element..<bound)
            }
        }
        
        return result
    }
}
