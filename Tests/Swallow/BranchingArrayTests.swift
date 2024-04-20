//
// Copyright (c) Vatsal Manot
//

import Compute
import XCTest

class BranchTest: XCTestCase {
    struct StringBranch: Hashable, ExpressibleByNilLiteral {
        let name: String
        
        init(nilLiteral: ()) {
            self.name = "main"
        }
        
        init(_ name: String) {
            self.name = name
        }
    }
    
    typealias BranchArray = BranchingArray<StringBranch, String>
    
    func testInitialSetup() {
        let array = BranchArray(initialElements: ["a", "b", "c"], branch: .init("main"))
        XCTAssertEqual(array.count, 3)
        XCTAssertEqual(array[0], "a")
        XCTAssertEqual(array[1], "b")
        XCTAssertEqual(array[2], "c")
    }
    
    func testBranching() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.branch(.init("feature"))
        
        XCTAssertEqual(array.count, 1) // Ensure "feature" branch has the same trunk
        array.commit(.init(insertions: [(1, "b")], deletions: []))
        array.checkout(.init("feature"))
        XCTAssertEqual(array.count, 1) // "feature" should not see "b" yet
        XCTAssertEqual(array[0], "a")
    }
    
    func testCommitting() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.commit(.init(insertions: [(1, "b")], deletions: []))
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array[1], "b")
    }
    
    func testCheckingOut() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.branch(.init("feature"))
        array.commit(.init(insertions: [(1, "b")], deletions: []))
        array.checkout(.init("feature"))
        
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], "a")
    }
    
    func testMerging() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.branch(.init("feature"))
        array.checkout(.init("feature"))
        array.commit(.init(insertions: [(1, "f")], deletions: []))
        array.checkout(.init("main"))
        array.commit(.init(insertions: [(1, "b")], deletions: []))
        
        array.checkout(.init("feature"))

        array.merge(
            .init("main"),
            into: .init("feature"),
            using: .combineUnique
        )
        
        XCTAssertEqual(array.count, 3)
        XCTAssertEqual(array[1], "b")
        XCTAssertEqual(array[2], "f")
    }
    
    func testRangeReplacement() {
        var array = BranchArray(initialElements: ["a", "b", "c", "d"], branch: .init("main"))
        array.replaceSubrange(1..<3, with: ["x", "y"])
        
        XCTAssertEqual(array.count, 4)
        XCTAssertEqual(array[1], "x")
        XCTAssertEqual(array[2], "y")
        XCTAssertEqual(array[3], "d")
    }
    
    func testAppend() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.append("b")
        
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array[1], "b")
    }
    
    func testRemoveAll() {
        var array = BranchArray(initialElements: ["a", "b", "c"], branch: .init("main"))
        array.removeAll()
        
        XCTAssertEqual(array.count, 0)
    }
    
    func testHistory() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.commit(.init(insertions: [(1, "b")], deletions: []))
        array.commit(.init(insertions: [(2, "c")], deletions: []))
        
        let history = array.history(in: .init("main"))
        XCTAssertEqual(history.count, 3)
        
        XCTAssertEqual(history[2].diff.insertions, [.init(offset: 0, element: "a")])
        XCTAssertEqual(history[1].diff.insertions, [.init(offset: 1, element: "b")])
        XCTAssertEqual(history[0].diff.insertions, [.init(offset: 2, element: "c")])
    }
        
    func testReset() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        let initialCommitID = array.currentCommit!
        array.commit(.init(insertions: [(1, "b")], deletions: []))
        
        array.reset(to: initialCommitID.id)
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], "a")
    }
    
    func testCherryPick() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.branch(.init("feature"))
        array.checkout(.init("feature"))
        array.commit(.init(insertions: [(1, "f")], deletions: []))
        let featureCommitID = array.currentCommit!
        array.checkout(.init("main"))
        
        array.cherryPick(featureCommitID.id)
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array[1], "f")
    }
    
    func testRevert() {
        var array = BranchArray(initialElements: ["a"], branch: .init("main"))
        array.commit(.init(insertions: [(1, "b")], deletions: []))
        let commitID = array.currentCommit!.id
        
        array.revert(commitID)
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], "a")
    }
}
