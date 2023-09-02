//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct _DictionarySnapshotOfTree<Node: ConstructibleTree & RecursiveTreeProtocol & Identifiable> where Node.Children: Collection, Node.Children.Element: Identifiable, Node.Children.Element.ID == Node.ID {
    public let values: [Node.ID: Node.TreeValue]
    public let childrenByParent: Set<ReferenceTree<Node.ID>>
    
    public init(from nodes: IdentifierIndexingArray<Node, Node.ID>) {
        var childrenByParent: [Node.ID: Set<Node.ID>] = [:]
        
        var nodeIDs: [Node.ID: ReferenceTree<Node.ID>] = [:]
        
        var allChildrenIDs: Set<Node.ID> = []
        
        for node in nodes {
            let childrenIDs = Set(node.children.map(\.id))
            
            childrenByParent[node.id] = childrenIDs
            
            allChildrenIDs.formUnion(childrenIDs)
        }
        
        let rootNodeIDs = Set(nodeIDs.keys).subtracting(allChildrenIDs)
        
        for (parentID, childrenIDs) in childrenByParent {
            let parentTree = nodeIDs[parentID, default: ReferenceTree(parentID)]
            
            nodeIDs[parentID] = parentTree
            
            for childID in childrenIDs {
                let childTree = nodeIDs[childID, default: ReferenceTree(childID)]
                nodeIDs[childID] = childTree
                parentTree.addChild(childTree)
            }
        }
        
        self.values = nodes.groupFirstOnly(by: \.id).mapValues({ $0.value })
        self.childrenByParent = Set(nodeIDs.filter({ rootNodeIDs.contains($0.key) }).values)
    }
}

extension _DictionarySnapshotOfTree {
    public enum CodingKeys: String, CodingKey {
        case values
        case childrenByParent
    }
}

extension _DictionarySnapshotOfTree: Encodable where Node.TreeValue: Encodable, Node.ID: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(values, forKey: .values)
        try container.encode(childrenByParent, forKey: .childrenByParent)
    }
}

extension _DictionarySnapshotOfTree: Decodable where Node.ID: Decodable, Node.TreeValue: Decodable, Node.Children: SequenceInitiableSequence {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.values = try container.decode([Node.ID: Node.TreeValue].self, forKey: .values)
        self.childrenByParent = try container.decode(Set<ReferenceTree<Node.ID>>.self, forKey: .childrenByParent)
    }
}

extension _DictionarySnapshotOfTree where Node: HomogenousTree, Node.Children: SequenceInitiableSequence {
    public func convert() -> [Node] {
        childrenByParent.map {
            $0.map(to: Node.self) {
                values[$0]!
            }
        }
    }
}
