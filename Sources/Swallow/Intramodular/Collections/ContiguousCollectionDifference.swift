//
// Copyright (c) Vatsal Manot
//

import Foundation

/// A type representing a collection of contiguous changes, either insertions or removals.
public struct ContiguousCollectionDifference<ChangeElements> {
    /// A type representing a contiguous change, either an insertion or removal.
    public enum ContiguousChange {
        /// An insertion of a contiguous range of elements.
        case insert(offsetRange: Range<Int>, elements: ChangeElements)
        /// A removal of a contiguous range of elements.
        case remove(offsetRange: Range<Int>, elements: ChangeElements)
    }
    
    public var insertions: [ContiguousChange]
    public var removals: [ContiguousChange]

    public init(changes: [ContiguousChange]) {
        self.insertions = changes.lazy.compactMap { change -> ContiguousChange? in
            guard case .insert = change else {
                return nil
            }
            
            return change
        }
        self.removals = changes.lazy.compactMap { change -> ContiguousChange? in
            guard case .remove = change else {
                return nil
            }
            
            return change
        }
    }
}

extension ContiguousCollectionDifference.ContiguousChange: Equatable where ChangeElements: Equatable {
    
}

extension CollectionDifference {
    public func toContiguousCollectionDifference() -> ContiguousCollectionDifference<[ChangeElement]> {
        var contiguousChanges: [ContiguousCollectionDifference<[ChangeElement]>.ContiguousChange] = []
        
        var currentOffsetRange: Range<Int>?
        var currentElements: [ChangeElement] = []
        var isInsertion: Bool?
                        
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
    public mutating func apply<C: Collection>(
        _ difference: ContiguousCollectionDifference<C>
    ) where C.Element == Element {
        // Applying the changes in reverse order to avoid messing with the offsets of subsequent changes
        for change in difference.removals.reversed() {
            switch change {
                case .insert:
                    assertionFailure()
                case let .remove(offsetRange, _):
                    let indexRange = index(startIndex, offsetBy: offsetRange.lowerBound)..<index(startIndex, offsetBy: offsetRange.upperBound)
                    removeSubrange(indexRange)
            }
        }
        
        for change in difference.insertions {
            switch change {
                case let .insert(offsetRange, elements):
                    let indexRange = index(startIndex, offsetBy: offsetRange.lowerBound)..<index(startIndex, offsetBy: offsetRange.lowerBound)
                    replaceSubrange(indexRange, with: elements)
                case .remove:
                    assertionFailure()
            }
        }
    }
}

extension NSMutableAttributedString {
    public func apply(
        _ difference: ContiguousCollectionDifference<NSAttributedString>
    ) {
        for change in difference.removals.reversed() {
            switch change {
                case .insert:
                    assertionFailure("Should not encounter an insertion in removals.")
                case let .remove(range, _):
                    let range = NSRange(
                        location: range.lowerBound,
                        length: range.upperBound - range.lowerBound
                    )
                    
                    self.replaceCharacters(in: range, with: "")
            }
        }
        
        for change in difference.insertions {
            switch change {
                case let .insert(range, string):
                    let offset = range.lowerBound
                    
                    self.insert(string, at: offset)
                case .remove:
                    assertionFailure("Should not encounter a removal in insertions.")
            }
        }
    }
}
