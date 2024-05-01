//
// Copyright (c) Vatsal Manot
//

import Swift

extension Collection {
    public typealias _EnumeratedSequence = Zip2Sequence<Self.Indices, Self>
    
    @_disfavoredOverload
    public func _enumerated() -> _EnumeratedSequence {
        Swift.zip(indices, self)
    }
}

extension Collection {
    public func lazySubsequences(
        matching predicate: @escaping (Element) -> Bool
    ) -> LazySequence<UnfoldSequence<SubSequence, Index>> {
        return sequence(state: startIndex) { index -> SubSequence? in
            guard let startIndex = self[index...].firstIndex(where: predicate) else {
                return nil
            }
            
            let endIndex = self[startIndex...].firstIndex(where: { !predicate($0) }) ?? self.endIndex
            
            index = endIndex
            
            return self[startIndex..<endIndex]
        }
        .lazy
    }
    
    public func enumerateLazySubsequences(
        matching predicate: @escaping (Element) -> Bool
    ) -> LazySequence<UnfoldSequence<(Range<Index>, SubSequence), Index>> {
        return sequence(state: startIndex) { index -> (Range<Index>, SubSequence)? in
            guard let startIndex = self[index...].firstIndex(where: predicate) else {
                return nil
            }
            
            let endIndex = self[startIndex...].firstIndex(where: { !predicate($0) }) ?? self.endIndex
            
            index = endIndex
            
            return (startIndex..<endIndex, self[startIndex..<endIndex])
        }
        .lazy
    }
}
