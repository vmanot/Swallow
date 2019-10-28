//
// Copyright (c) Vatsal Manot
//

import Swift

extension CountableRange {
    public func allNonEmptySubRanges() -> [CountableRange<Index>] {        
        guard count != 0 else {
            return []
        }

        var result = Array<CountableRange<Index>>(capacity: numericCast(count * count.successor() / 2))
        
        for element in self {
            var bound = element
            
            while bound != upperBound {
                bound = bound.advanced(by: 1)
                result += element..<bound
            }
        }
        
        return result
    }
}
