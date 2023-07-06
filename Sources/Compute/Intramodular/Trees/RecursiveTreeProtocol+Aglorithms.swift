//
// Copyright (c) Vatsal Manot
//

import Swallow

extension RecursiveTreeProtocol {
    public func filter(
        _ predicate: (TreeValue) throws -> Bool
    ) rethrows -> ArrayTree<TreeValue>? {
        guard try predicate(value) else {
            return nil
        }
        
        return .init(value: value, children: try children.compactMap({
            try $0.filter(predicate)
        }))
    }
    
    public func filterChildren(
        _ predicate: (TreeValue) throws -> Bool
    ) rethrows -> ArrayTree<TreeValue> {
        .init(value: value, children: try children.compactMap({
            try $0.filter(predicate)
        }))
    }
}

extension RecursiveTreeProtocol {
    public func forEachDepthFirst(
        _ body: (TreeValue) -> Void
    ) {
        body(value)
        
        children.forEach({ child in
            child.forEachDepthFirst(body)
        })
    }
    
    public mutating func forEachDepthFirst(
        mutating body: (inout TreeValue) -> Void
    ) where Self: MutableRecursiveTree & HomogenousTree {
        body(&value)
        
        children._forEach(mutating: { child in
            child.forEachDepthFirst(mutating: body)
        })
    }
    
    public func forEachPostOrder(
        _ body: (TreeValue) -> Void
    ) {
        for child in children {
            child.forEachPostOrder(body)
        }
        
        body(value)
    }
}
