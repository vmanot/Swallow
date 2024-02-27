//
// Copyright (c) Vatsal Manot
//

import Swallow
import XCTest

#if false
class ContiguousCollectionDifferenceTests: XCTestCase {
    func testSingleInsertion() {
        let diff = CollectionDifference([.insert(offset: 1, element: 4, associatedWith: nil)])!
        let contiguousDiff = diff.toContiguousCollectionDifference()
        let expectedChanges = [ContiguousCollectionDifference<Int>.ContiguousChange.insert(offsetRange: 1..<2, elements: [4])]
        XCTAssertEqual(contiguousDiff.changes, expectedChanges)
    }
    
    func testSingleRemoval() {
        let diff = CollectionDifference([.remove(offset: 2, element: 3, associatedWith: nil)])!
        let contiguousDiff = diff.toContiguousCollectionDifference()
        let expectedChanges = [ContiguousCollectionDifference<Int>.ContiguousChange.remove(offsetRange: 2..<3, elements: [3])]
        XCTAssertEqual(contiguousDiff.changes, expectedChanges)
    }
    
    func testContiguousInsertions() {
        let diff = CollectionDifference([.insert(offset: 1, element: 4, associatedWith: nil), .insert(offset: 2, element: 5, associatedWith: nil)])!
        let contiguousDiff = diff.toContiguousCollectionDifference()
        let expectedChanges = [ContiguousCollectionDifference<Int>.ContiguousChange.insert(offsetRange: 1..<3, elements: [4, 5])]
        XCTAssertEqual(contiguousDiff.changes, expectedChanges)
    }
    
    func testContiguousRemovals() {
        let diff = CollectionDifference([.remove(offset: 2, element: 3, associatedWith: nil), .remove(offset: 3, element: 4, associatedWith: nil)])!
        let contiguousDiff = diff.toContiguousCollectionDifference()
        let expectedChanges = [ContiguousCollectionDifference<Int>.ContiguousChange.remove(offsetRange: 2..<4, elements: [3, 4])]
        XCTAssertEqual(contiguousDiff.changes, expectedChanges)
    }
    
    func testMixedChanges() {
        let diff = CollectionDifference([
            .insert(offset: 1, element: 4, associatedWith: nil),
            .remove(offset: 3, element: 3, associatedWith: nil),
            .insert(offset: 4, element: 6, associatedWith: nil)
        ])!
        let contiguousDiff = diff.toContiguousCollectionDifference()
        let expectedChanges = [
            ContiguousCollectionDifference<Int>.ContiguousChange.remove(offsetRange: 3..<4, elements: [3]),
            ContiguousCollectionDifference<Int>.ContiguousChange.insert(offsetRange: 1..<2, elements: [4]),
            ContiguousCollectionDifference<Int>.ContiguousChange.insert(offsetRange: 4..<5, elements: [6])
        ]
        XCTAssertEqual(contiguousDiff.changes, expectedChanges)
    }
    
    func testEmptyDifference() {
        let diff = CollectionDifference<Int>([])!
        let contiguousDiff = diff.toContiguousCollectionDifference()
        XCTAssertTrue(contiguousDiff.changes.isEmpty)
    }

    func testApplyingInsertion() {
        var array = [1, 2, 3]
        let changes = [
            ContiguousCollectionDifference<Int>.ContiguousChange.insert(offsetRange: 1..<2, elements: [4, 5])
        ]
        let difference = ContiguousCollectionDifference(changes: changes)
        array.apply(difference)
        XCTAssertEqual(array, [1, 4, 5, 2, 3])
    }
    
    func testApplyingRemoval() {
        var array = [1, 2, 3, 4, 5]
        let changes = [
            ContiguousCollectionDifference<Int>.ContiguousChange.remove(offsetRange: 1..<3, elements: [2, 3])
        ]
        let difference = ContiguousCollectionDifference(changes: changes)
        array.apply(difference)
        XCTAssertEqual(array, [1, 4, 5])
    }
    
    func testApplyingMultipleChanges() {
        var array = [1, 2, 3, 4, 5]
        let changes = [
            ContiguousCollectionDifference<Int>.ContiguousChange.remove(offsetRange: 3..<5, elements: [3, 4]),
            ContiguousCollectionDifference<Int>.ContiguousChange.insert(offsetRange: 1..<2, elements: [6]),
        ]
        let difference = ContiguousCollectionDifference(changes: changes)
        array.apply(difference)
        XCTAssertEqual(array, [1, 6, 2, 5])
    }
    
    func testApplyingEmptyChange() {
        var array = [1, 2, 3, 4, 5]
        let difference = ContiguousCollectionDifference<Int>(changes: [])
        array.apply(difference)
        XCTAssertEqual(array, [1, 2, 3, 4, 5]) // No changes
    }
}
#endif
