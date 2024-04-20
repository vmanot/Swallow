//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct BranchingArray<Branch: Hashable, Element: Equatable> {
    private var _trunk: [Element]
    private var _commits: [CommitID: Commit]
    private var _branches: [Branch: CommitID]
    private var _currentBranch: Branch
    
    public var count: Int {
        _trunk.count
    }
    
    public var branches: [Branch] {
        Array(_branches.keys)
    }
    
    public var currentBranch: Branch {
        get {
            _currentBranch
        } set {
            checkout(newValue)
        }
    }
    
    public var currentCommit: Commit? {
        guard let commitID = _branches[_currentBranch] else {
            return nil
        }
        
        return _commits[commitID]
    }
    
    public init(
        initialElements: [Element] = [],
        branch: Branch
    ) {
        let initialCommitID = CommitID()
        _trunk = initialElements
        
        let initialDiff = Difference(
            insertions: initialElements.enumerated().map { (index, element) in
                (offset: index, element: element)
            }, deletions: []
        )
        
        _commits = [initialCommitID: Commit(parent: nil, diff: initialDiff, id: initialCommitID)]
        _branches = [branch: initialCommitID]
        _currentBranch = branch
    }
}

extension BranchingArray {
    public func history(in branch: Branch) -> [Commit] {
        guard let commitID = _branches[branch] else {
            return []
        }
        
        return generateCommitPath(from: commitID)
    }
    
    public func commitExists(_ commitID: CommitID) -> Bool {
        _commits[commitID] != nil
    }
    
    public mutating func branch(_ branchName: Branch) {
        _branches[branchName] = _branches[_currentBranch]
    }
    
    public mutating func commit(_ difference: Difference) {
        assert(!difference.isEmpty, "Cannot commit an empty diff")
        
        assert(!difference.isEmpty)
        
        let newCommitID = CommitID()
        _commits[newCommitID] = Commit(parent: _branches[_currentBranch], diff: difference, id: newCommitID)
        _branches[_currentBranch] = newCommitID
        _trunk = applyDiff(difference, to: _trunk)
    }
    
    public mutating func checkout(_ branchName: Branch) {
        guard let commitID = _branches[branchName] else {
            return
        }
        _trunk = regenerateTrunk(from: commitID)
        _currentBranch = branchName
    }
    
    public mutating func merge(
        _ sourceBranch: Branch,
        into destinationBranch: Branch,
        resolvingConflictsWith resolver: (Difference, Difference) -> Difference
    ) {
        guard
            let sourceCommitID = _branches[sourceBranch],
            let destinationCommitID = _branches[destinationBranch],
            sourceCommitID != destinationCommitID
        else {
            return
        }
        
        if let commonAncestorCommitID = findCommonAncestor(sourceCommitID, destinationCommitID) {
            mergeWithCommonAncestor(
                sourceCommitID: sourceCommitID,
                destinationCommitID: destinationCommitID,
                commonAncestorCommitID: commonAncestorCommitID,
                destinationBranch: destinationBranch,
                resolver: resolver
            )
        } else {
            mergeWithoutCommonAncestor(
                sourceCommitID: sourceCommitID,
                destinationCommitID: destinationCommitID,
                destinationBranch: destinationBranch,
                resolver: resolver
            )
        }
    }
    
    public func difference(
        from startCommitID: CommitID,
        to endCommitID: CommitID
    ) -> Difference? {
        guard commitExists(startCommitID), commitExists(endCommitID) else {
            return nil
        }
        
        return accumulatedDifference(from: startCommitID, to: endCommitID)
    }
    
    public mutating func reset(
        to commitID: CommitID
    ) {
        guard let branch = _branches.first(where: { history(in: $0.key).contains(where: { $0.id == commitID }) })?.key else {
            assertionFailure("Commit not found in any branch")
            
            return
        }
        
        // Reset the branch to the specified commit
        _branches[branch] = commitID
        
        // Regenerate the trunk based on the new commit
        _trunk = regenerateTrunk(from: commitID)
        
        // Update the current branch
        _currentBranch = branch
    }
    
    public mutating func cherryPick(_ commitID: CommitID) {
        guard let commit = _commits[commitID] else {
            assertionFailure("Commit '\(commitID)' does not exist")
            
            return
        }
        
        self.commit(commit.diff)
    }
    
    public mutating func revert(_ commitID: CommitID) {
        guard let commit = _commits[commitID] else {
            assertionFailure("Commit '\(commitID)' does not exist")
            
            return
        }
        
        let revertedDiff = Difference(
            insertions: commit.diff.deletions.map({ .init(offset: $0.offset, element: $0.element) }),
            deletions: commit.diff.insertions.map({ .init(offset: $0.offset, element: $0.element) })
        )
        
        self.commit(revertedDiff)
    }
}

extension BranchingArray {
    public struct Difference: Equatable {
        public struct Insertion: Equatable {
            public let offset: Int
            public let element: Element
            
            public init(offset: Int, element: Element) {
                self.offset = offset
                self.element = element
            }
        }
        
        public struct Deletion: Equatable {
            public let offset: Int
            public let element: Element
            
            public init(offset: Int, element: Element) {
                self.offset = offset
                self.element = element
            }
        }
        
        public var insertions: [Insertion]
        public var deletions: [Deletion]
        
        public var isEmpty: Bool {
            insertions.isEmpty && deletions.isEmpty
        }
        
        public init(
            insertions: [Insertion],
            deletions: [Deletion]
        ) {
            self.insertions = insertions
            self.deletions = deletions
        }
        
        @_disfavoredOverload
        public init(
            insertions: [(offset: Int, element: Element)],
            deletions: [(offset: Int, element: Element)]
        ) {
            self.insertions = insertions.map({ .init(offset: $0.offset, element: $0.element) })
            self.deletions = deletions.map({ .init(offset: $0.offset, element: $0.element) })
        }
    }
    
    public struct CommitID: Hashable {
        private let uuid: UUID = UUID()
    }
    
    public struct Commit {
        public let parent: CommitID?
        public let diff: Difference
        public let id: CommitID
    }
}

// MARK: - Merge Helpers

extension BranchingArray {
    private mutating func mergeWithCommonAncestor(
        sourceCommitID: CommitID,
        destinationCommitID: CommitID,
        commonAncestorCommitID: CommitID,
        destinationBranch: Branch,
        resolver: (Difference, Difference) -> Difference
    ) {
        assert(_commits[sourceCommitID] != nil, "Source commit does not exist")
        assert(_commits[destinationCommitID] != nil, "Destination commit does not exist")
        
        let sourceDifference = accumulatedDifference(from: sourceCommitID, to: commonAncestorCommitID)
        let destinationDifference = accumulatedDifference(from: destinationCommitID, to: commonAncestorCommitID)
        
        let resolvedDiff = resolver(sourceDifference, destinationDifference)
        
        guard !resolvedDiff.isEmpty else {
            return
        }
        
        let newCommitID = CommitID()
        _commits[newCommitID] = Commit(parent: destinationCommitID, diff: resolvedDiff, id: newCommitID)
        _branches[destinationBranch] = newCommitID
        
        _trunk = regenerateTrunk(from: newCommitID)
    }
    
    private mutating func mergeWithoutCommonAncestor(
        sourceCommitID: CommitID,
        destinationCommitID: CommitID,
        destinationBranch: Branch,
        resolver: (Difference, Difference) -> Difference
    ) {
        assert(_commits[sourceCommitID] != nil, "Source commit does not exist")
        assert(_commits[destinationCommitID] != nil, "Destination commit does not exist")
        
        let sourceDifference = accumulatedDifference(from: sourceCommitID)
        let destinationDifference = accumulatedDifference(from: destinationCommitID)
        
        let resolvedDiff = resolver(sourceDifference, destinationDifference)
        
        guard !resolvedDiff.isEmpty else {
            return
        }
        
        let newCommitID = CommitID()
        _commits[newCommitID] = Commit(parent: destinationCommitID, diff: resolvedDiff, id: newCommitID)
        _branches[destinationBranch] = newCommitID
        
        _trunk = regenerateTrunk(from: newCommitID)
    }
    
    private func accumulatedDifference(from commitID: CommitID) -> Difference {
        var currentCommitID: CommitID? = commitID
        var resultDiff = Difference(insertions: [], deletions: [])
        
        while let commitID = currentCommitID {
            if let commit = _commits[commitID] {
                resultDiff = mergeDiffs(commit.diff, into: resultDiff)
                currentCommitID = commit.parent
            } else {
                break
            }
        }
        
        return resultDiff
    }
    
    private func accumulatedDifference(from startCommitID: CommitID, to endCommitID: CommitID) -> Difference {
        var currentCommitID: CommitID? = startCommitID
        var resultDiff = Difference(insertions: [], deletions: [])
        
        while let commitID = currentCommitID, commitID != endCommitID {
            if let commit = _commits[commitID] {
                resultDiff = mergeDiffs(commit.diff, into: resultDiff)
                currentCommitID = commit.parent
            } else {
                break
            }
        }
        
        return resultDiff
    }
    
    private func doDifferencesConflict(_ source: Difference, _ destination: Difference) -> Bool {
        let sourceRanges = source.insertions.map { $0.offset } + source.deletions.map { $0.offset }
        let destinationRanges = destination.insertions.map { $0.offset } + destination.deletions.map { $0.offset }
        return !Set(sourceRanges).isDisjoint(with: Set(destinationRanges))
    }
    
    private func mergeDiffs(_ srcDiff: Difference, into destDiff: Difference) -> Difference {
        var combinedInsertions = srcDiff.insertions
        var combinedDeletions = destDiff.deletions
        
        for insertion in destDiff.insertions {
            if !combinedInsertions.contains(where: { $0.offset == insertion.offset && $0.element == insertion.element }) {
                combinedInsertions.append(insertion)
            }
        }
        
        for deletion in srcDiff.deletions {
            if !combinedDeletions.contains(where: { $0.offset == deletion.offset && $0.element == deletion.element }) {
                combinedDeletions.append(deletion)
            }
        }
        
        return Difference(insertions: combinedInsertions, deletions: combinedDeletions)
    }
}

// MARK: - Conformances

extension BranchingArray: CustomStringConvertible {
    public var description: String {
        Array(_trunk).description
    }
}

extension BranchingArray: RandomAccessCollection {
    public var startIndex: Int {
        _trunk.startIndex
    }
    
    public var endIndex: Int {
        _trunk.endIndex
    }
    
    public subscript(index: Int) -> Element {
        _trunk[index]
    }
    
    public func index(after i: Int) -> Int {
        _trunk.index(after: i)
    }
    
    public func index(before i: Int) -> Int {
        _trunk.index(before: i)
    }
    
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        _trunk.index(i, offsetBy: distance)
    }
    
    public func distance(from start: Int, to end: Int) -> Int {
        _trunk.distance(from: start, to: end)
    }
}

extension BranchingArray: RangeReplaceableCollection where Branch: ExpressibleByNilLiteral {
    public init() {
        self.init(initialElements: [], branch: nil)
    }
    
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        let diff = Difference(insertions: [], deletions: _trunk[bounds].enumerated().map { (bounds.lowerBound + $0, $1) })
        commit(diff)
    }
    
    public mutating func replaceSubrange<C>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C : Collection, Element == C.Element {
        let diff = Difference(
            insertions: Array(newElements.enumerated().map { (subrange.lowerBound + $0, $1) }),
            deletions: _trunk[subrange].enumerated().map { (subrange.lowerBound + $0, $1) }
        )
        commit(diff)
    }
    
    public mutating func append(_ newElement: Element) {
        commit(Difference(insertions: [(_trunk.endIndex, newElement)], deletions: []))
    }
    
    public mutating func append<S>(
        contentsOf newElements: S
    ) where S : Sequence, Element == S.Element {
        let diff = Difference(
            insertions: newElements.enumerated().map { (_trunk.endIndex + $0, $1) },
            deletions: []
        )
        commit(diff)
    }
    
    public mutating func removeAll(
        keepingCapacity keepCapacity: Bool = false
    ) {
        let diff = Difference(insertions: [], deletions: _trunk.enumerated().map { $0 })
        commit(diff)
        
        if !keepCapacity {
            _trunk.removeAll(keepingCapacity: false)
            _commits = [_branches[_currentBranch]!: _commits[_branches[_currentBranch]!]!]
        }
    }
}

// MARK: - Supplementary

extension BranchingArray {
    public enum DefaultConflictResolutionStrategy {
        case preferSource
        case preferDestination
        case combineUnique
        case custom((BranchingArray.Difference, BranchingArray.Difference) -> BranchingArray.Difference)
        
        func resolve(_ source: BranchingArray.Difference, _ destination: BranchingArray.Difference) -> BranchingArray.Difference {
            switch self {
                case .preferSource:
                    return source
                case .preferDestination:
                    return destination
                case .combineUnique:
                    let combinedInsertions: [Difference.Insertion] = source.insertions + destination.insertions.filter { destinationInsertion in
                        !source.insertions.contains(where: { $0.offset == destinationInsertion.offset }) &&
                        !source.deletions.contains(where: { $0.offset == destinationInsertion.offset })
                    }
                    let combinedDeletions: [Difference.Deletion] = source.deletions + destination.deletions.filter { destinationDeletion in
                        !source.deletions.contains(where: { $0.offset == destinationDeletion.offset }) &&
                        !source.insertions.contains(where: { $0.offset == destinationDeletion.offset })
                    }
                    return BranchingArray<Branch, Element>.Difference(insertions: combinedInsertions, deletions: combinedDeletions)
                case .custom(let resolver):
                    return resolver(source, destination)
            }
        }
    }
    
    public mutating func merge(
        _ sourceBranch: Branch,
        into destinationBranch: Branch,
        using strategy: DefaultConflictResolutionStrategy
    ) {
        merge(sourceBranch, into: destinationBranch, resolvingConflictsWith: strategy.resolve)
    }
}

// MARK: - Internal

extension BranchingArray {
    private func applyDiff(_ diff: Difference, to trunk: [Element]) -> [Element] {
        var result = trunk
        
        for deletion in diff.deletions.sorted(by: { $0.offset > $1.offset }) {
            if deletion.offset < result.count {
                result.remove(at: deletion.offset)
            }
        }
        
        for insertion in diff.insertions.sorted(by: { $0.offset < $1.offset }) {
            if insertion.offset <= result.count {
                result.insert(insertion.element, at: insertion.offset)
            }
        }
        
        return result
    }
    
    private func regenerateTrunk(from commitID: CommitID) -> [Element] {
        assert(_commits[commitID] != nil, "Commit '\(commitID)' does not exist")
        
        let commitPath = generateCommitPath(from: commitID)
        var currentTrunk = [Element]()
        
        for commit in commitPath.reversed() {
            currentTrunk = applyDiff(commit.diff, to: currentTrunk)
        }
        
        return currentTrunk
    }
    
    private func generateCommitPath(from commitID: CommitID) -> [Commit] {
        var commitPath = [Commit]()
        var currentCommitID: CommitID? = commitID
        
        while let currentCommit: Commit = currentCommitID.flatMap({ _commits[$0] }) {
            commitPath.append(currentCommit)
            
            if let parentID = currentCommit.parent {
                if currentCommitID == parentID {
                    assertionFailure("this should not be happening")
                    
                    break
                }
                
                currentCommitID = parentID
            } else {
                break
            }
        }
        
        if !commitPath.isEmpty {
            assert(commitPath.contains(where: { !$0.diff.isEmpty }))
        }
        
        return commitPath
    }
    
    private func findCommonAncestor(_ commitID1: CommitID, _ commitID2: CommitID) -> CommitID? {
        var ancestors1 = Set<CommitID>()
        var currentCommitID1: CommitID? = commitID1
        
        while let commitID = currentCommitID1 {
            ancestors1.insert(commitID)
            currentCommitID1 = _commits[commitID]?.parent
        }
        
        var currentCommitID2: CommitID? = commitID2
        
        while let commitID = currentCommitID2 {
            if ancestors1.contains(commitID) {
                return commitID
            }
            currentCommitID2 = _commits[commitID]?.parent
        }
        
        return nil
    }
}
