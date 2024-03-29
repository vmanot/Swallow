//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A directed acyclic graph of nodes.
public final class _AnyPatternMatchingGraph<G: _StaticGraphTypeDefinition>: _PatternMatchingDirectedAcyclicGraph {
    public typealias Node = _AnyPatternMatchingGraphNode<G>
    public typealias NodeValue = Node.Value
    public typealias Edge = _AnyPatternMatchingGraphEdge<G>
    
    private var nodes: [Node.ID: NodeValue] = [:]
    private var valueGenerationIDs: [Node.ID: Int] = [:]
    private var incomingEdges: [Node.ID: Set<Edge>] = [:]
    private var outgoingEdges: [Node.ID: Set<Edge>] = [:]
    private var visitedForCycleDetection: Set<Node.ID> = []
    
    private var cachedPatternMatches: [AnyHashable: _SubgraphMatchCache<Node>] = [:]
    
    /// Creates a new node in the DAG.
    public func makeNode(_ value: NodeValue) -> Node {
        let id = Node.ID()
        nodes[id] = value
        valueGenerationIDs[id] = 0
        incomingEdges[id] = []
        outgoingEdges[id] = []
        return Node(id, in: self)
    }
    
    /// Adds an edge from the source node to the destination node in the DAG.
    /// Returns `false` if adding the edge would introduce a cycle.
    @discardableResult
    public func addEdge(_ edge: Node.Edge) -> Bool {
        if visitedForCycleDetection.contains(edge.destination.id) {
            return false
        }
        visitedForCycleDetection.insert(edge.source.id)
        visitedForCycleDetection.insert(edge.destination.id)
        
        outgoingEdges[edge.source.id, default: []].insert(edge)
        incomingEdges[edge.destination.id, default: []].insert(edge)
        
        // Invalidate cached matches
        invalidateCachedMatches(forNodeWithID: edge.source.id)
        invalidateCachedMatches(forNodeWithID: edge.destination.id)
        
        return true
    }
    
    func value(forNodeWithID id: Node.ID) -> NodeValue {
        nodes[id]!
    }
    
    func setValue(_ value: NodeValue, forNodeWithID id: Node.ID) {
        nodes[id] = value
        valueGenerationIDs[id, default: 0] += 1
        invalidateCachedMatches(forNodeWithID: id)
    }
    
    func incomingEdges(forNodeWithID id: Node.ID) -> Set<Node.Edge> {
        incomingEdges[id] ?? []
    }
    
    func outgoingEdges(forNodeWithID id: Node.ID) -> Set<Node.Edge> {
        outgoingEdges[id] ?? []
    }
    
    func cachedMatch<P: _GraphPatternExpression<Node>>(
        _ pattern: P,
        fromNodeWithID id: Node.ID
    ) -> [GraphMatch<Node>] {
        if let cachedMatches = cachedPatternMatches[pattern.id],
           cachedMatches.valueGenerationIDs == currentValueGenerationIDs(in: cachedMatches.matches) {
            return cachedMatches.matches
        }
        
        let graphMatches = pattern.match(from: Node(id, in: self))
        
        cachedPatternMatches[pattern.id] = _SubgraphMatchCache(
            valueGenerationIDs: currentValueGenerationIDs(in: graphMatches),
            matches: graphMatches
        )
        
        return graphMatches
    }
    
    private func currentValueGenerationIDs(
        in matches: [GraphMatch<Node>]
    ) -> [Node.ID: Int] {
        var valueGenerationIDs: [Node.ID: Int] = [:]
        
        for match in matches {
            for node in match.nodes {
                valueGenerationIDs[node.id] = self.valueGenerationIDs[node.id] ?? 0
            }
        }
        
        return valueGenerationIDs
    }
    
    func invalidateCachedMatches(forNodeWithID id: Node.ID) {
        cachedPatternMatches.removeAll()
    }
    
    /// Matches the given pattern expression against the DAG starting from the specified node.
    /// Returns an array of matched subgraphs.
    /// The matches are cached and lazily invalidated based on the node's value generation identifiers.
    public func match<P: _GraphPatternExpression<Node>>(
        _ pattern: P,
        from node: Node
    ) -> [GraphMatch<Node>] {
        return cachedMatch(pattern, fromNodeWithID: node.id)
    }
}

/// Represents cached pattern matches for a node.
struct _SubgraphMatchCache<Node: _PatternMatchingGraphNode> {
    let valueGenerationIDs: [Node.ID: Int]
    let matches: [GraphMatch<Node>]
    
    init(
        valueGenerationIDs: [Node.ID: Int],
        matches: [GraphMatch<Node>]
    ) {
        self.valueGenerationIDs = valueGenerationIDs
        self.matches = matches
    }
}

/// A node in a directed acyclic graph.
@frozen
public struct _AnyPatternMatchingGraphNode<G: _StaticGraphTypeDefinition>: _PatternMatchingGraphNode {
    public typealias Value = G.Node.Value
    public typealias ID = _AutoIncrementingIdentifier<Int>
    public typealias Edge = _AnyPatternMatchingGraphEdge<G>
    
    public let id: _AutoIncrementingIdentifier<Int>
    
    private unowned let owner: _AnyPatternMatchingGraph<G>
    
    init(_ id: ID, in graph: _AnyPatternMatchingGraph<G>) {
        self.id = id
        self.owner = graph
    }
    
    public var value: Value {
        get {
            owner.value(forNodeWithID: id)
        }
    }
    
    public var incomingEdges: Set<Edge> {
        owner.incomingEdges(forNodeWithID: id)
    }
    
    public var outgoingEdges: Set<Edge> {
        owner.outgoingEdges(forNodeWithID: id)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// An edge in a directed acyclic graph.
@frozen
public struct _AnyPatternMatchingGraphEdge<G: _StaticGraphTypeDefinition>: _PatternMatchingGraphEdge {
    public let source: _AnyPatternMatchingGraphNode<G>
    public let destination: _AnyPatternMatchingGraphNode<G>
    public let payload: G.Edge
    
    public init(
        from source: Node,
        to destination: Node,
        payload: G.Edge
    ) {
        self.source = source
        self.destination = destination
        self.payload = payload
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(source)
        hasher.combine(destination)
        hasher.combine(payload)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.source == rhs.source && lhs.destination == rhs.destination && lhs.payload == rhs.payload
    }
}
