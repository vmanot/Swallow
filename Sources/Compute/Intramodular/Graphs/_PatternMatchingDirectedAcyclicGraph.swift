//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _PatternMatchingDirectedAcyclicGraph<Node> {
    associatedtype Node: _PatternMatchingGraphNode
}

public protocol _PatternMatchingGraphNode<Value>: HashEquatable, Identifiable {
    associatedtype Value
    associatedtype Edge: _PatternMatchingGraphEdge<Self>
    
    var value: Value { get }
    
    var incomingEdges: Set<Edge> { get }
    var outgoingEdges: Set<Edge> { get }
}

public protocol _PatternMatchingGraphEdge<Node>: Hashable {
    associatedtype Node: _PatternMatchingGraphNode
    
    var source: Node { get }
    var destination: Node { get }
}
