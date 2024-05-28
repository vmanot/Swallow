//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct BranchingDictionary<Branch: Hashable, Key: Hashable, Value: Equatable> {
    private var _trunk: [Key: Value]
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
        initialElements: [Key: Value] = [:],
        branch: Branch
    ) {
        let initialCommitID = CommitID()
        _trunk = initialElements
        
        let initialDiff = Difference(
            insertions: initialElements.map { (key, value) in
                (key: key, value: value)
            }, deletions: []
        )
        
        _commits = [initialCommitID: Commit(parent: nil, diff: initialDiff, id: initialCommitID)]
        _branches = [branch: initialCommitID]
        _currentBranch = branch
    }
}

extension BranchingDictionary {
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
            insertions: commit.diff.deletions.map({ .init(key: $0.key, value: $0.value) }),
            deletions: commit.diff.insertions.map({ .init(key: $0.key, value: $0.value) })
        )
        
        self.commit(revertedDiff)
    }
}

extension BranchingDictionary {
    public struct Difference: Equatable {
        public struct Insertion: Equatable {
            public let key: Key
            public let value: Value
            
            public init(key: Key, value: Value) {
                self.key = key
                self.value = value
            }
        }
        
        public struct Deletion: Equatable {
            public let key: Key
            public let value: Value
            
            public init(key: Key, value: Value) {
                self.key = key
                self.value = value
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
            insertions: [(key: Key, value: Value)],
            deletions: [(key: Key, value: Value)]
        ) {
            self.insertions = insertions.map({ .init(key: $0.key, value: $0.value) })
            self.deletions = deletions.map({ .init(key: $0.key, value: $0.value) })
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

extension BranchingDictionary {
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
        let sourceKeys = source.insertions.map { $0.key } + source.deletions.map { $0.key }
        let destinationKeys = destination.insertions.map { $0.key } + destination.deletions.map { $0.key }
        return !Set(sourceKeys).isDisjoint(with: Set(destinationKeys))
    }
    
    private func mergeDiffs(_ srcDiff: Difference, into destDiff: Difference) -> Difference {
        var combinedInsertions = srcDiff.insertions
        var combinedDeletions = destDiff.deletions
        
        for insertion in destDiff.insertions {
            if !combinedInsertions.contains(where: { $0.key == insertion.key && $0.value == insertion.value }) {
                combinedInsertions.append(insertion)
            }
        }
        
        for deletion in srcDiff.deletions {
            if !combinedDeletions.contains(where: { $0.key == deletion.key && $0.value == deletion.value }) {
                combinedDeletions.append(deletion)
            }
        }
        
        return Difference(insertions: combinedInsertions, deletions: combinedDeletions)
    }
}

// MARK: - Conformances

extension BranchingDictionary: CustomStringConvertible {
    public var description: String {
        _trunk.description
    }
}

// MARK: - Supplementary

extension BranchingDictionary {
    public enum DefaultConflictResolutionStrategy {
        case preferSource
        case preferDestination
        case combineUnique
        case custom((BranchingDictionary.Difference, BranchingDictionary.Difference) -> BranchingDictionary.Difference)
        
        func resolve(_ source: BranchingDictionary.Difference, _ destination: BranchingDictionary.Difference) -> BranchingDictionary.Difference {
            switch self {
                case .preferSource:
                    return source
                case .preferDestination:
                    return destination
                case .combineUnique:
                    let combinedInsertions: [Difference.Insertion] = source.insertions + destination.insertions.filter { destinationInsertion in
                        !source.insertions.contains(where: { $0.key == destinationInsertion.key }) &&
                        !source.deletions.contains(where: { $0.key == destinationInsertion.key })
                    }
                    let combinedDeletions: [Difference.Deletion] = source.deletions + destination.deletions.filter { destinationDeletion in
                        !source.deletions.contains(where: { $0.key == destinationDeletion.key }) &&
                        !source.insertions.contains(where: { $0.key == destinationDeletion.key })
                    }
                    return BranchingDictionary<Branch, Key, Value>.Difference(insertions: combinedInsertions, deletions: combinedDeletions)
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

extension BranchingDictionary {
    private func applyDiff(_ diff: Difference, to trunk: [Key: Value]) -> [Key: Value] {
        var result = trunk
        
        for deletion in diff.deletions {
            result.removeValue(forKey: deletion.key)
        }
        
        for insertion in diff.insertions {
            result[insertion.key] = insertion.value
        }
        
        return result
    }
    
    private func regenerateTrunk(from commitID: CommitID) -> [Key: Value] {
        assert(_commits[commitID] != nil, "Commit '\(commitID)' does not exist")
        
        let commitPath = generateCommitPath(from: commitID)
        var currentTrunk = [Key: Value]()
        
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
