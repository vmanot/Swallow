//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol HomogenousTree: RecursiveTreeProtocol where Children.Element == Self {
    
}

// MARK: - Constructors

extension HomogenousTree where Self: ConstructibleTree, Children: RangeReplaceableCollection {
    public init(
        value: TreeValue,
        recursiveChildren: some RandomAccessCollection<TreeValue>
    ) {
        var currentChild: Self?
        
        for child in recursiveChildren.reversed() {
            if let _currentChild = currentChild {
                currentChild = .init(value: child, children: [_currentChild])
            } else {
                currentChild = .init(value: child, children: [])
            }
        }
        
        self = .init(value: value, children: currentChild.map({ .init([$0]) }) ?? .init())
    }
    
    public init?(recursiveValues: some RandomAccessCollection<TreeValue>) {
        guard let first = recursiveValues.first else {
            return nil
        }
        
        self.init(value: first, recursiveChildren: recursiveValues.dropFirst())
    }
}

// MARK: - Extensions

extension HomogenousTree {
    public func recursiveFirst(
        where predicate: (TreeValue) -> Bool
    ) -> Self? {
        if predicate(value) {
            return self
        }
        
        for child in children {
            if let found = child.recursiveFirst(where: { predicate($0) }) {
                return found
            }
        }
        
        return nil
    }
}

extension HomogenousTree {
    public func reduceBottomUp<T: ThrowingMergeOperatable>(
        buildPartial: (Self) throws -> T,
        combine: ((parent: Self, partial: T)) throws -> T
    ) throws -> T {
        let result = try children
            .map { child -> T in
                if child.children.isEmpty {
                    return try buildPartial(child)
                } else {
                    return try child.reduceBottomUp(
                        buildPartial: buildPartial,
                        combine: combine
                    )
                }
            }
            .reduce({ try $0.merging($1) })
        
        guard let result else {
            return try buildPartial(self)
        }
        
        return try combine((self, result))
    }
    
    public func reduceBottomUp<T: ThrowingMergeOperatable>(
        buildPartial: (Self) throws -> [T],
        combine: ((parent: Self, partial: T)) throws -> T
    ) throws -> T? {
        let result = try children
            .compactMap { child -> T? in
                if child.children.isEmpty {
                    return try buildPartial(child).reduce({ try $0.merging($1) })
                } else {
                    return try child.reduceBottomUp(
                        buildPartial: buildPartial,
                        combine: combine
                    )
                }
            }
            .reduce({ try $0.merging($1) })
        
        guard let result else {
            return try buildPartial(self).reduce({ try $0.merging($1) })
        }
        
        return try combine((self, result))
    }
}

// MARK: - Implemented Conformances

extension HomogenousTree where Self: Hashable, TreeValue: Hashable, Children: Collection, Children.Index: Hashable {
    public func hash(into hasher: inout Hasher) {
        for node in AnySequence({ _enumerated().makeDepthFirstIterator() }) {
            node.indexPath.hash(into: &hasher)
            node.value.hash(into: &hasher)
        }
    }
}
