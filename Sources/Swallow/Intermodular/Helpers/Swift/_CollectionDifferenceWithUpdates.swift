//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Swift

public struct _CollectionDifferenceWithUpdates<ChangeElement> {
    public enum Change {
        case insert(offset: Int, element: ChangeElement, associatedWith: Int?)
        case remove(offset: Int, element: ChangeElement, associatedWith: Int?)
        case update(offset: Int, element: ChangeElement)
    }
    
    public typealias Insertion = CollectionDifference<ChangeElement>._Insertion
    public typealias Update = CollectionDifference<ChangeElement>._Update
    public typealias Removal = CollectionDifference<ChangeElement>._Removal
    
    public let insertions: [Insertion]
    public let updates: [Update]
    public let removals: [Removal]
    
    public init(insertions: [Insertion], updates: [Update], removals: [Removal]) {
        self.insertions = insertions
        self.updates = updates
        self.removals = removals
    }
}

// MARK: - Supplementary

extension BidirectionalCollection {
    // TODO: Write tests.
    public func _differenceWithUpdates<Other: BidirectionalCollection<Element>>(
        from other: Other,
        by areEquivalent: (Element, Element) -> Bool
    ) throws -> _CollectionDifferenceWithUpdates<Element> where Other.Index == Index {
        typealias Result = _CollectionDifferenceWithUpdates<Element>
        
        var difference = self.difference(from: other, by: areEquivalent)
        let updates: [CollectionDifference<Element>._Update]
        
        do {
            updates = try difference._removeUpdates(by: areEquivalent)
        } catch {
            assertionFailure(error)
            
            return .init(
                insertions: difference._insertions,
                updates: [],
                removals: difference._removals
            )
        }
        
        return .init(
            insertions: difference._insertions,
            updates: updates,
            removals: difference._removals
        )
    }
}

// MARK: - Auxiliary

extension CollectionDifference {
    public mutating func _removeUpdates(
        by areEquivalent: (ChangeElement, ChangeElement) -> Bool
    ) throws -> [_Update] {
        let insertionsEnumerated = self.insertions._enumerated().lazy.compactMap { (index: Int, element: Change) -> (index: Int, element: _Insertion)? in
            guard let insertion = element.insertion else {
                return nil
            }
            
            return (index: index, element: insertion)
        }
        
        let removalsEnumerated = self.insertions._enumerated().lazy.compactMap { (index: Int, element: Change) -> (index: Int, element: _Removal)? in
            guard let removal = element.removal else {
                return nil
            }
            
            return (index: index, element: removal)
        }
        
        var updates: [_Update] = []
        
        var indicesOfInsertionsToDelete: [Int] = []
        var indicesOfRemovalsToDelete: [Int] = []
        
        for (insertionIndex, insertion) in insertionsEnumerated {
            if let (removalIndex, _) = removalsEnumerated.first(where: { $0.element.offset == insertion.offset && !areEquivalent($0.element.element, insertion.element) }) {
                indicesOfInsertionsToDelete.append(insertionIndex)
                indicesOfRemovalsToDelete.append(removalIndex)
                
                updates.append(.init(offset: insertion.offset, element: insertion.element))
            }
        }
        
        var newInsertions = self.insertions
        var newRemovals = self.removals
        
        newInsertions.remove(elementsAtIndices: indicesOfInsertionsToDelete)
        newRemovals.remove(elementsAtIndices: indicesOfRemovalsToDelete)
        
        self = try CollectionDifference(newInsertions + newRemovals).unwrap()
        
        return updates
    }
}
