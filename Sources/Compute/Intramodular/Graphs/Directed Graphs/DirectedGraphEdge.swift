//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol DirectedGraphEdge<Vertex> {
    associatedtype Vertex
}

/// An type that represents an edge in a directed acyclic graph.
public protocol DirectedAcyclicGraphEdge<Vertex>: DirectedGraphEdge {
    
}

