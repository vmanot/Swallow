//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TreeChains<Tree: HomogenousTree>: Sequence where Tree.Children: Collection {
    public typealias Element = [Tree]
    
    fileprivate let root: Tree
    
    public var _naiveArrayValue: [Element] {
        root._allChains()
    }
    
    public subscript(_ path: TreeIndexPath<Tree>) -> Element {
        root._chain(for: path)!
    }
    
    /// All tree chains stemming from the base chain defined by the given path.
    public func stemming(
        from path: TreeIndexPath<Tree>
    ) -> [Element]? {
        guard let chain = root._chain(for: path) else {
            assertionFailure()
            
            return nil
        }
        
        guard let chainLast = chain.last else {
            return nil
        }
        
        return chainLast.chains.map({ chain.appending(contentsOf: $0) })
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        .init(_naiveArrayValue.makeIterator())
    }
}

extension TreeChains: Collection {
    public typealias Index = Array<Element>.Index
    
    public var startIndex: Index {
        _naiveArrayValue.startIndex
    }
    
    public var endIndex: Index {
        _naiveArrayValue.endIndex
    }
    
    public subscript(position: Index) -> Element {
        _naiveArrayValue[position]
    }
}

extension TreeChains: CustomStringConvertible {
    public var description: String {
        _naiveArrayValue.description
    }
}

extension HomogenousTree where Children: Collection {
    public var chains: TreeChains<Self> {
        TreeChains(root: self)
    }

    fileprivate func _chain(
        for path: TreeIndexPath<Self>
    ) -> [Self]? {
        var current: Self? = self
        var chain: [Self] = []
        
        for index in path.indices {
            guard let child = current?.children[index] else {
                return nil
            }
            
            chain.append(child)
            
            current = child
        }
        
        return chain
    }
    
    fileprivate func _allChains(
        till shouldStopAt: (Self) throws -> Bool
    ) rethrows -> [TreeChains<Self>.Element] {
        var result: [TreeChains<Self>.Element] = []
        var currentChain: [Self] = []
        
        func depthFirstSearch(_ node: Self) throws {
            currentChain.append(node)
            
            if node.children.isEmpty {
                result.append(currentChain) // Reached a leaf node, add the current path to the resul
            } else {
                // Continue searching for paths in the child nodes
                for child in node.children {
                    guard try !shouldStopAt(child) else {
                        result.append(currentChain)
                        
                        break
                    }
                    
                    try depthFirstSearch(child)
                }
            }
            
            // Backtrack to the parent node
            currentChain.removeLast()
        }
        
        try depthFirstSearch(self)
        
        return result
    }
    
    fileprivate func _allChains() -> [TreeChains<Self>.Element] {
        _allChains(till: { _ in false })
    }
}

/*struct TreeChainsIterator<Tree: HomogenousTree>: IteratorProtocol where Tree.Children: Collection {
 public typealias Element = [Tree]
 
 let base: Tree
 var result: [[Element]] = []
 var currentChain: Element = []
 let terminator: (Tree) throws -> Bool
 
 mutating func next() -> [Tree]? {
 var result: [Element] = []
 
 depthFirstSearch(base)
 }
 
 mutating func depthFirstSearch(_ node: Tree) -> {
 currentChain.append(node)
 
 if node.children.isEmpty {
 result.append(currentChain) // Reached a leaf node, add the current path to the resul
 } else {
 // Continue searching for paths in the child nodes
 for child in node.children {
 guard try !terminator(child) else {
 result.append(currentChain)
 
 break
 }
 
 try depthFirstSearch(child)
 }
 }
 
 // Backtrack to the parent node
 currentChain.removeLast()
 }
 
 try depthFirstSearch(self)
 }
 */
