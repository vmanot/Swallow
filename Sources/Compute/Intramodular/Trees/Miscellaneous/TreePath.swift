//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TreeIndexPath<Tree: TreeProtocol>: Equatable where Tree.Children: Collection {
    public let indices: [Tree.Children.Index]
    
    public init(indices: [Tree.Children.Index] = []) {
        self.indices = indices
    }
    
    public func appending(_ index: Tree.Children.Index) -> Self {
        Self(indices: indices + [index])
    }
}

extension TreeIndexPath {
    public func dropLast() -> Self {
        TreeIndexPath(indices: Array(indices.dropLast()))
    }
}

extension TreeIndexPath: Hashable where Tree.Children.Index: Hashable {
    
}

extension TreeIndexPath: Sendable where Tree.Children.Index: Sendable {
    
}

extension HomogenousTree where Children: Collection {    
    public subscript(path: TreeIndexPath<Self>) -> Self? {
        var currentTree = self
        
        for index in path.indices {
            if currentTree.children.indices.contains(index) {
                currentTree = currentTree.children[index]
            } else {
                return nil
            }
        }
        
        return currentTree
    }
}
