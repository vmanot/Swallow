//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A pattern expression for matching subgraphs in a DAG.
public protocol _GraphPatternExpression<Node>: Identifiable {
    associatedtype Node: _PatternMatchingGraphNode
    
    /// Matches the pattern against the given node in the DAG.
    /// Returns an array of matched subgraphs, where each subgraph is represented as an array of nodes and edges.
    func match(from node: Node) -> [GraphMatch<Node>]
}

/// A primitive pattern expression for matching subgraphs in a DAG.
public protocol PrimitiveGraphPatternExpression<Node>: _GraphPatternExpression {
    /// Matches the pattern against the given node in the DAG.
    /// Returns an array of matched subgraphs, where each subgraph is represented as an array of nodes and edges.
    /// This method is optimized for primitive pattern types.
    func primitiveMatch(from node: Node) -> [GraphMatch<Node>]
}

extension PrimitiveGraphPatternExpression {
    public func match(from node: Node) -> [GraphMatch<Node>] {
        return primitiveMatch(from: node)
    }
}

public enum GraphPatternBuilder {
    
}

extension GraphPatternBuilder {
    /// A pattern that matches a single node based on a predicate.
    public struct NodePattern<Node: _PatternMatchingGraphNode>: PrimitiveGraphPatternExpression {
        private let predicate: (Node.Value) -> Bool
        public let id: _AutoIncrementingIdentifier<Int>
        
        public init(_ predicate: @escaping (Node.Value) -> Bool) {
            self.predicate = predicate
            self.id = _AutoIncrementingIdentifier<Int>()
        }
        
        public func primitiveMatch(
            from node: Node
        ) -> [GraphMatch<Node>] {
            if predicate(node.value) {
                return [GraphMatch(nodes: [node], edges: [])]
            }
            
            return []
        }
    }
    
    /// A pattern that matches the destination node of an edge matched by a subpattern.
    public struct DestinationOfPattern<Node: _PatternMatchingGraphNode>: PrimitiveGraphPatternExpression {
        private let subpattern: any _GraphPatternExpression<Node>
        
        public init(_ subpattern: any _GraphPatternExpression<Node>) {
            self.subpattern = subpattern
        }
        
        public var id: AnyHashable {
            Hashable2ple((ObjectIdentifier(Self.self), subpattern.id.erasedAsAnyHashable))
        }
        
        public func primitiveMatch(
            from node: Node
        ) -> [GraphMatch<Node>] {
            let sourceMatches = subpattern.match(from: node)
             
            return sourceMatches.flatMap { (sourceMatch: GraphMatch<Node>) -> [GraphMatch] in
                sourceMatch.last!.outgoingEdges.map { (edge: Node.Edge) in
                    GraphMatch(
                        nodes: sourceMatch.nodes + [edge.destination],
                        edges: sourceMatch.edges + [edge]
                    )
                }
            }
        }
    }
    
    /// A pattern that matches the source node of an edge matched by a subpattern.
    public struct SourceOfPattern<Node: _PatternMatchingGraphNode>: PrimitiveGraphPatternExpression {
        private let subpattern: any _GraphPatternExpression<Node>
        
        public init(_ subpattern: any _GraphPatternExpression<Node>) {
            self.subpattern = subpattern
        }
        
        public var id: some Hashable {
            Hashable2ple((ObjectIdentifier(Self.self), subpattern.id.erasedAsAnyHashable))
        }
        
        public func primitiveMatch(
            from node: Node
        ) -> [GraphMatch<Node>] {
            let destinationMatches: [GraphMatch<Node>] = subpattern.match(from: node)
            
            return destinationMatches.flatMap { (destinationMatch: GraphMatch<Node>) in
                destinationMatch.first!.incomingEdges.map { (edge: Node.Edge) -> GraphMatch in
                    GraphMatch(
                        nodes: Array(element: edge.source).appending(contentsOf: destinationMatch.nodes),
                        edges: Array(element: edge).appending(contentsOf: destinationMatch.edges)
                    )
                }
            }
        }
    }
    
    /// A pattern that matches the leaf nodes in the DAG.
    public struct LeafNodesPattern<Node: _PatternMatchingGraphNode>: Initiable, PrimitiveGraphPatternExpression {
        public init() {
            
        }
        
        public var id: AnyHashable {
            ObjectIdentifier(Self.self)
        }
        
        public func primitiveMatch(
            from node: Node
        ) -> [GraphMatch<Node>] {
            if node.outgoingEdges.isEmpty {
                return [GraphMatch(nodes: [node], edges: [])]
            }
            
            return []
        }
    }
    
    /// A pattern that matches a sequence of nodes based on an array of subpatterns.
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public struct SequencePattern<Node: _PatternMatchingGraphNode>: _GraphPatternExpression {
        private let subpatterns: [any _GraphPatternExpression<Node>]
        
        public init(
            _ subpatterns: [any _GraphPatternExpression<Node>]
        ) {
            self.subpatterns = subpatterns
        }
        
        public var id: some Hashable {
            let result: [AnyHashable] = subpatterns.map({ $0.id.erasedAsAnyHashable })
            
            return result
        }
        
        public func match(
            from node: Node
        ) -> [GraphMatch<Node>] {
            var matches = [GraphMatch<Node>]()
            
            func backtrack(
                _ currentNode: Node,
                _ currentSubpatternIndex: Int,
                _ currentMatch: GraphMatch<Node>
            ) {
                if currentSubpatternIndex == subpatterns.count {
                    matches.append(currentMatch)
                    return
                }
                
                let currentSubpattern: any _GraphPatternExpression<Node> = subpatterns[currentSubpatternIndex]
                let submatches: [GraphMatch<Node>] = currentSubpattern.match(from: currentNode)
                
                for submatch in submatches {
                    if let lastMatchedNode = submatch.nodes.last {
                        backtrack(
                            lastMatchedNode,
                            currentSubpatternIndex + 1,
                            GraphMatch(
                                nodes: currentMatch.nodes + submatch.nodes,
                                edges: currentMatch.edges + submatch.edges
                            )
                        )
                    }
                }
            }
            
            backtrack(node, 0, GraphMatch(nodes: [], edges: []))
            
            return matches
        }
    }
    
    /// A pattern that matches a range of nodes as a wildcard.
    public struct WildcardPattern<Node: _PatternMatchingGraphNode>: _GraphPatternExpression {
        private let range: ClosedRange<Int>?
        
        public init(range: ClosedRange<Int>? = nil) {
            self.range = range
        }
        
        public var id: some Hashable {
            return range?.hashValue ?? 0
        }
        
        public func match(
            from node: Node
        ) -> [GraphMatch<Node>] {
            var matches = [GraphMatch<Node>]()
            
            func backtrack(_ currentNode: Node, _ currentMatch: GraphMatch<Node>) {
                if let range = range {
                    if range.contains(currentMatch.nodes.count) {
                        matches.append(currentMatch)
                    }
                    
                    if currentMatch.nodes.count < range.upperBound {
                        for edge in currentNode.outgoingEdges {
                            backtrack(
                                edge.destination,
                                GraphMatch(
                                    nodes: currentMatch.nodes + [edge.destination],
                                    edges: currentMatch.edges + [edge]
                                )
                            )
                        }
                    }
                } else {
                    matches.append(currentMatch)
                    
                    for edge in currentNode.outgoingEdges {
                        backtrack(
                            edge.destination,
                            GraphMatch(
                                nodes: currentMatch.nodes + [edge.destination],
                                edges: currentMatch.edges + [edge]
                            )
                        )
                    }
                }
            }
            
            backtrack(node, GraphMatch(nodes: [node], edges: []))
            
            return matches
        }
    }
    
    public struct NegationPattern<Node: _PatternMatchingGraphNode>: _GraphPatternExpression {
        private let subpattern: any _GraphPatternExpression<Node>
        
        public init(_ subpattern: any _GraphPatternExpression<Node>) {
            self.subpattern = subpattern
        }
        
        public var id: some Hashable {
            Hashable2ple((ObjectIdentifier(Self.self), subpattern.id.erasedAsAnyHashable))
        }
        
        public func match(from node: Node) -> [GraphMatch<Node>] {
            let matches = subpattern.match(from: node)
            let allNodes = Set(matches.flatMap{ $0.nodes })
            let negativeSingleton = GraphMatch(nodes: [node], edges: [])
            
            if allNodes.contains(node) {
                return []
            } else {
                return [negativeSingleton]
            }
        }
    }
    
    public struct ConcatenationPattern<Node: _PatternMatchingGraphNode>: _GraphPatternExpression {
        private let lhs: any _GraphPatternExpression<Node>
        private let rhs: any _GraphPatternExpression<Node>
        
        public init(
            _ lhs: any _GraphPatternExpression<Node>,
            _ rhs: any _GraphPatternExpression<Node>
        ) {
            self.lhs = lhs
            self.rhs = rhs
        }
        
        public var id: some Hashable {
            Hashable2ple((lhs.id.erasedAsAnyHashable, rhs.id.erasedAsAnyHashable))
        }
        
        public func match(from node: Node) -> [GraphMatch<Node>] {
            lhs.match(from: node) + rhs.match(from: node)
        }
    }
    
    public struct MatchAnyPattern<Node: _PatternMatchingGraphNode>: PrimitiveGraphPatternExpression {
        public init() {
            
        }
        
        public var id: AnyHashable {
            ObjectIdentifier(Self.self)
        }
        
        public func primitiveMatch(from node: Node) -> [GraphMatch<Node>] {
            [GraphMatch(nodes: [node], edges: [])]
        }
    }
    
    public struct MatchAnyEdgePattern<Node: _PatternMatchingGraphNode>: _GraphPatternExpression {
        public init() {
            
        }
        
        public var id: AnyHashable {
            ObjectIdentifier(Self.self)
        }
        
        public func match(from node: Node) -> [GraphMatch<Node>] {
            node.outgoingEdges.map { edge in
                GraphMatch(nodes: [node, edge.destination], edges: [edge])
            }
        }
    }
}

// MARK: - Auxiliary

/// Represents a matched subgraph in the DAG.
public struct GraphMatch<Node: _PatternMatchingGraphNode>: ExpressibleByArrayLiteral, RandomAccessCollection {
    public typealias ArrayLiteralElement = Node
    public typealias Element = Node
    
    public let nodes: [Node]
    public let edges: [Node.Edge]
    
    public init(nodes: [Node], edges: [Node.Edge]) {
        self.nodes = nodes
        self.edges = edges
    }
    
    public var startIndex: Int {
        nodes.startIndex
    }
    
    public var endIndex: Int {
        nodes.endIndex
    }
    
    public subscript(position: Int) -> Element {
        self.nodes[position]
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        nodes.makeIterator().eraseToAnyIterator()
    }
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.nodes = elements
        self.edges = []
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        self.init(nodes: lhs.nodes + rhs.nodes, edges: lhs.edges + rhs.edges)
    }
}
