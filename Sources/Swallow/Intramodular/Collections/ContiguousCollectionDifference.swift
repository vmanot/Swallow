//
// Copyright (c) Vatsal Manot
//

import Foundation

/// A type representing a collection of contiguous changes, either insertions or removals.
public struct ContiguousCollectionDifference<ChangeElement> {
    /// A type representing a contiguous change, either an insertion or removal.
    public enum ContiguousChange {
        /// An insertion of a contiguous range of elements.
        case insert(offsetRange: Range<Int>, elements: [ChangeElement])
        /// A removal of a contiguous range of elements.
        case remove(offsetRange: Range<Int>, elements: [ChangeElement])
    }
    
    public enum ContiguousChangeType {
        case insert
        case remove
    }
    
    /// An array of the contiguous changes.
    public var changes: [ContiguousChange]
    
    public init(changes: [ContiguousChange]) {
        self.changes = changes
    }
}

extension ContiguousCollectionDifference.ContiguousChange: Equatable where ChangeElement: Equatable {
    
}

extension CollectionDifference {
    public func toContiguousCollectionDifference() -> ContiguousCollectionDifference<ChangeElement> {
        var contiguousChanges: [ContiguousCollectionDifference<ChangeElement>.ContiguousChange] = []
        
        var currentOffsetRange: Range<Int>?
        var currentElements: [ChangeElement] = []
        var isInsertion: Bool?
        
        var changes: [Change]
                
        for change in self {
            switch change {
                case .insert(let offset, let element, _):
                    if let isInsertion = isInsertion, isInsertion, let range = currentOffsetRange, range.upperBound == offset {
                        // Continuation of an insertion
                        currentOffsetRange = range.lowerBound..<range.upperBound + 1
                        currentElements.append(element)
                    } else {
                        // A new insertion
                        if let range = currentOffsetRange {
                            contiguousChanges.append(isInsertion! ? .insert(offsetRange: range, elements: currentElements) : .remove(offsetRange: range, elements: currentElements))
                        }
                        currentOffsetRange = offset..<offset + 1
                        currentElements = [element]
                        isInsertion = true
                    }
                case .remove(let offset, let element, _):
                    if let isInsertion = isInsertion, !isInsertion, let range = currentOffsetRange, range.lowerBound == (offset + 1) {
                        // Continuation of a removal
                        currentOffsetRange = range.lowerBound - 1..<range.upperBound
                        currentElements.insert(element, at: 0)
                    } else {
                        // A new removal
                        if let range = currentOffsetRange {
                            contiguousChanges.append(isInsertion! ? .insert(offsetRange: range, elements: currentElements) : .remove(offsetRange: range, elements: currentElements))
                        }
                        currentOffsetRange = offset..<offset + 1
                        currentElements = [element]
                        isInsertion = false
                    }
            }
        }
        
        if let range = currentOffsetRange {
            contiguousChanges.append(isInsertion! ? .insert(offsetRange: range, elements: currentElements) : .remove(offsetRange: range, elements: currentElements))
        }
        
        return ContiguousCollectionDifference(changes: contiguousChanges)
    }
}

extension RangeReplaceableCollection {
    public mutating func apply(_ difference: ContiguousCollectionDifference<Element>) {
        // Applying the changes in reverse order to avoid messing with the offsets of subsequent changes
        for change in difference.changes.reversed() {
            switch change {
                case let .insert(offsetRange, elements):
                    let indexRange = index(startIndex, offsetBy: offsetRange.lowerBound)..<index(startIndex, offsetBy: offsetRange.lowerBound)
                    replaceSubrange(indexRange, with: elements)
                case let .remove(offsetRange, _):
                    let indexRange = index(startIndex, offsetBy: offsetRange.lowerBound)..<index(startIndex, offsetBy: offsetRange.upperBound)
                    removeSubrange(indexRange)
            }
        }
    }
}
