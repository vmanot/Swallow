//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TreeValuesTraversalSequence<Tree: RecursiveTreeProtocol>: Sequence {
    private let base: Tree
    private let traversal: TreeTraversalAlgorithmType
    
    init(from base: Tree, traversal: TreeTraversalAlgorithmType) {
        self.base = base
        self.traversal = traversal
    }
    
    public var count: Int {
        var count = 0
        
        base.forEachDepthFirst({ _ in count += 1 })
        
        return count
    }
    
    public func makeIterator() -> AnyIterator<Tree.TreeValue> {
        switch traversal {
            case .depthFirst:
                return AnyIterator(
                    AnySequence({ Array(element: base.eraseToAnyTree()).depthFirstIterator(children: { $0.children }) })
                        .lazy
                        .map({ $0.value })
                        .makeIterator()
                )
            case .breadthFirst:
                return AnyIterator(
                    AnySequence({ Array(element: base.eraseToAnyTree()).breadthFirstIterator(children: { $0.children }) })
                        .lazy
                        .map({ $0.value })
                        .makeIterator()
                )
        }
    }
}

extension RecursiveTreeProtocol {
    public func values(
        traversal: TreeTraversalAlgorithmType
    ) -> TreeValuesTraversalSequence<Self> {
        .init(from: self, traversal: traversal)
    }
    
    public func values() -> TreeValuesTraversalSequence<Self> {
        values(traversal: .breadthFirst)
    }
}
