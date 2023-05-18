//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

/// A directed acyclic graph.
public protocol DirectedAcyclicGraph: DirectedGraph where Edge: DirectedAcyclicGraphEdge<Vertex> {
    
}
