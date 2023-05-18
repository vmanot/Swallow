//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A simple reference-based tree data structure for Swift.
///
/// This structure is *not* a value type.
public final class ReferenceTree<Element>: ReferenceParentPointerTree {
    public typealias Children = [ReferenceTree<Element>]
    
    public private(set) weak var parent: ReferenceTree<Element>?
    
    public let element: Element
    
    public var value: Element {
        element
    }
    
    public private(set) var children: Children
    
    public init(_ element: Element, children: Children = []) {
        self.element = element
        self.children = children
        
        for child in children {
            assert(child.parent == nil, "Attempted to insert a child with an existing parent: \(child.parent!)")
            
            child.parent = self
        }
    }
    
    public func addChild(_ node: ReferenceTree<Element>) {
        assert(node.parent == nil, "Attempted to insert a node with an existing parent: \(node.parent!)")
        
        children.append(node)
        
        node.parent = self
    }
}

extension HomogenousTree {
    public func map<T: ConstructibleTree & HomogenousTree & Identifiable>(
        to type: T.Type,
        _ transform: (TreeValue) -> T.TreeValue
    ) -> T where T.Children: SequenceInitiableSequence {
        return T(
            value: transform(value),
            children: T.Children(self.children.map({ $0.map(to: type, transform) }))
        )
    }
}

// MARK: - Conformances

extension ReferenceTree: CustomStringConvertible {
    public var description: String {
        guard !children.isEmpty else {
            return String(describing: element)
        }
        
        var result = ""
        
        _writeDescription(to: &result, prefix: "", childrenPrefix: "")
        
        return result
    }
    
    func _writeDescription(to output: inout String, prefix: String, childrenPrefix: String) {
        output.append(prefix)
        output.append(String(describing: element))
        output.append("\n")
        
        for (index, child) in children.enumerated() {
            if index != (children.count - 1) {
                child._writeDescription(
                    to: &output,
                    prefix: childrenPrefix + "├── ",
                    childrenPrefix: childrenPrefix + "│   "
                )
            } else {
                child._writeDescription(
                    to: &output,
                    prefix: childrenPrefix + "└── ",
                    childrenPrefix: childrenPrefix + "    "
                )
            }
        }
    }
}

extension ReferenceTree {
    private enum CodingKeys: String, CodingKey {
        case element
        case children
    }
}

extension ReferenceTree: Decodable where Element: Decodable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let element = try container.decode(Element.self, forKey: .element)
        let children = try container.decode([ReferenceTree<Element>].self, forKey: .children)
        
        self.init(element, children: children)
    }
}

extension ReferenceTree: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(element, forKey: .element)
        try container.encode(children, forKey: .children)
    }
}

extension ReferenceTree: Equatable where Element: Equatable {
    public static func == (lhs: ReferenceTree, rhs: ReferenceTree) -> Bool {
        lhs.parent === rhs.parent && lhs.element == rhs.element && lhs.children == rhs.children
    }
}

extension ReferenceTree: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        if let parent = parent {
            hasher.combine(ObjectIdentifier(parent))
        }
        
        hasher.combine(element)
        hasher.combine(children)
    }
}
