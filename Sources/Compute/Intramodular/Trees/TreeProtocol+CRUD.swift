//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension MutableRecursiveTree where Self: HomogenousTree, Children: RangeReplaceableCollection {
    public mutating func insertChild(
        _ child: Self,
        at index: Children.Index
    ) {
        children.insert(child, at: index)
    }
    
    public mutating func insertChild(
        value: TreeValue,
        at index: Children.Index
    ) where Self: ConstructibleTree {
        children.insert(.init(value: value, children: .init()), at: index)
    }
    
    @discardableResult
    public mutating func removeChild(at index: Children.Index) -> Self {
        children.remove(at: index)
    }
    
    public mutating func removeAllChildren(
        where predicate: (Children.Element) -> Bool
    ) {
        children.removeAll(where: predicate)
    }
    
    public mutating func appendChild(_ child: Self) {
        children.append(child)
    }
    
    public mutating func appendChild(
        value: TreeValue
    ) where Self: ConstructibleTree {
        children.append(.init(value: value, children: .init()))
    }
    
    public func child(at index: Children.Index) -> Self? {
        children.indices.contains(index) ? children[index] : nil
    }
    
    public func indexOfChild(where predicate: (Self) -> Bool) -> Children.Index? {
        children.firstIndex(where: predicate)
    }
}

extension ConstructibleTree where Self: MutableRecursiveTree & HomogenousTree, Children: RangeReplaceableCollection {
    public mutating func insertElement(
        _ element: TreeValue,
        at indexPath: IndexPath
    ) {
        guard !indexPath.isEmpty else {
            appendChild(Self(value: element, children: .init()))
            return
        }
        
        var tree = self
        var remainingPath = indexPath
        
        while !remainingPath.isEmpty {
            let index = remainingPath.removeFirst()
            
            if let child = tree.child(at: tree.children.index(atDistance: index)) {
                tree = child
            } else {
                tree.appendChild(Self(value: element, children: .init()))
                
                break
            }
        }
    }
    
    @discardableResult
    public mutating func removeElement(
        at indexPath: IndexPath
    ) -> TreeValue? where Children: MutableCollection {
        guard let firstIndex = indexPath.first.map({ children.index(atDistance: $0) }) else {
            return nil
        }
        
        if indexPath.count == 1 {
            return removeChild(at: firstIndex).value
        } else {
            return children[firstIndex].removeElement(at: IndexPath(indexes: indexPath.dropFirst()))
        }
    }
}
