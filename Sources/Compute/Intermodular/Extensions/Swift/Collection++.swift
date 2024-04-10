//
// Copyright (c) Vatsal Manot
//

import Swift

extension Collection where Element: Hashable {
    public func _asSet() -> Set<Element> {
        return Set(self)
    }
}

extension Collection where Element: Equatable {
    /// The Levenshtein distance between the receiver and the comparate.
    public func minimumEditDistance(to other: Self) -> Int {
        let sCount = count
        let oCount = other.count
        
        guard sCount != 0 else {
            return oCount
        }
        
        guard oCount != 0 else {
            return sCount
        }
        
        var mat: [[Int]] = Array(repeating: Array(repeating: 0, count: oCount + 1), count: sCount + 1)
        
        for i in 0...sCount {
            mat[i][0] = i
        }
        
        for j in 0...oCount {
            mat[0][j] = j
        }
        
        for j in 1...oCount {
            for i in 1...sCount {
                if self[atDistance: i - 1] == other[atDistance: j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]
                } else {
                    let del = mat[i - 1][j] + 1
                    let ins = mat[i][j - 1] + 1
                    let sub = mat[i - 1][j - 1] + 1
                    
                    mat[i][j] = Swift.min(Swift.min(del, ins), sub)
                }
            }
        }
        
        return mat[sCount][oCount]
    }
}
