//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

public struct ArrayTree<T>: ConstructibleTree, HomogenousTree {
    public typealias Value = T
    public typealias Children = ArrayTreeChildren<T>
    
    public var value: Value
    public var children: Children
    
    public init(value: Value, children: Children = []) {
        self.value = value
        self.children = children
    }
    
    public init(
        _ value: TreeValue,
        children: () -> Children
    ) {
        self.init(value: value, children: children())
    }
}

extension ArrayTree where T: Hashable {
    private enum MergeError: Error {
        case duplicateValueOnDifferentLevel
    }

    public func mergeLevelwise(
        with other: ArrayTree<T>
    ) throws -> ArrayTree<T> {
        var valueToLevel: [T: Int] = [:]
        
        func assignLevelsToValues(tree: ArrayTree<T>, currentLevel: Int) throws {
            if let existingLevel = valueToLevel[tree.value], existingLevel != currentLevel {
                throw MergeError.duplicateValueOnDifferentLevel
            }
            
            valueToLevel[tree.value] = currentLevel
            
            for child in tree.children {
                try assignLevelsToValues(tree: child, currentLevel: currentLevel + 1)
            }
        }
        
        try assignLevelsToValues(tree: self, currentLevel: 0)
        try assignLevelsToValues(tree: other, currentLevel: 0)
        
        var currentValueMap: [T: [ArrayTree<T>]] = [:]
        
        func groupChildren(tree: ArrayTree<T>) {
            if currentValueMap[tree.value] == nil {
                currentValueMap[tree.value] = []
            }
            
            currentValueMap[tree.value]?.append(tree)
            
            for child in tree.children {
                groupChildren(tree: child)
            }
        }
        
        groupChildren(tree: self)
        groupChildren(tree: other)
        
        func combineChildren(
            trees: ArrayTreeChildren<T>,
            currentLevel: Int
        ) -> [ArrayTree<T>] {
            var combinedChildren: [ArrayTree<T>] = []
            
            for tree in trees {
                let siblings = currentValueMap[tree.value]?.filter({ $0.value != tree.value })
                var newChildren = tree.children
                
                if let siblings = siblings, !siblings.isEmpty {
                    for sibling in siblings {
                        newChildren += sibling.children
                    }
                }
                
                let sortedCombinedChildren = combineChildren(
                    trees: newChildren,
                    currentLevel: currentLevel + 1
                )
                
                combinedChildren.append(
                    ArrayTree(
                        value: tree.value,
                        children: sortedCombinedChildren
                    )
                )
            }
            
            return combinedChildren
                .distinct()
                .sorted(by: { valueToLevel[$0.value]! < valueToLevel[$1.value]! })
        }
        
        let root = ArrayTree(
            value: self.value,
            children: combineChildren(
                trees: ArrayTreeChildren((self.children + other.children).distinct()),
                currentLevel: 1
            )
        )
        
        return root
    }
}

// MARK: - Conformances

extension ArrayTree: CustomStringConvertible {
    public var description: String {
        dumpTree(descriptionForValue: { _ReadableCustomStringConvertible(from: $0).description })
    }
}

extension ArrayTree: Equatable where T: Equatable {
    
}

extension ArrayTree: Hashable where T: Hashable {
    
}

extension ArrayTree: Sendable where T: Sendable {
    
}

extension ArrayTree: ExpressibleByArrayLiteral where T: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T.ArrayLiteralElement...) {
        self.init(value: .init(_arrayLiteral: elements))
    }
    
    public init(
        _ value: TreeValue,
        children: () -> [T.ArrayLiteralElement]
    ) {
        self.init(
            value: value,
            children: [.init(value: T.init(_arrayLiteral: children()), children: [])]
        )
    }
    
    public init(
        _ value: T.ArrayLiteralElement,
        children: () -> [T.ArrayLiteralElement]
    ) {
        self.init(.init(arrayLiteral: value), children: children)
    }
    
    public init(
        _ value: T.ArrayLiteralElement,
        child: () -> T.ArrayLiteralElement
    ) {
        self.init(.init(arrayLiteral: value), children: { [child()] })
    }
    
    public init(
        _ value: T.ArrayLiteralElement
    ) {
        self.init(.init(arrayLiteral: value), children: { [] })
    }
}

extension ArrayTree: ExpressibleByBooleanLiteral where T: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: T.BooleanLiteralType) {
        self.init(value: .init(booleanLiteral: value))
    }
}

extension ArrayTree: ExpressibleByFloatLiteral where T: ExpressibleByFloatLiteral {
    public init(floatLiteral value: T.FloatLiteralType) {
        self.init(value: .init(floatLiteral: value))
    }
}

extension ArrayTree: ExpressibleByIntegerLiteral where T: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: T.IntegerLiteralType) {
        self.init(value: .init(integerLiteral: value))
    }
}

extension ArrayTree: ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringLiteral where T: ExpressibleByStringLiteral {
    public init(stringLiteral value: T.StringLiteralType) {
        self.init(value: .init(stringLiteral: value))
    }
}
