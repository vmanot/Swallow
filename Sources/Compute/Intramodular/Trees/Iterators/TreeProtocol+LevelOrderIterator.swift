//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct LevelOrderIterator<Tree: HomogenousTree>: IteratorProtocol {
    public typealias Element = Tree
    
    private var queue: [Tree]
    
    public init(root: Tree) {
        self.queue = [root]
    }
    
    public mutating func next() -> Element? {
        guard !queue.isEmpty else {
            return nil
        }
        
        let node = queue.removeFirst()
        
        queue.append(contentsOf: node.children)
        
        return node
    }
}

extension HomogenousTree {
    public func makeLevelOrderIterator() -> LevelOrderIterator<Self> {
        LevelOrderIterator(root: self)
    }
}
