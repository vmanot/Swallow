//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol DirectedGraph {
    associatedtype Vertex
    associatedtype Edge
    
    associatedtype Vertices: Collection where Vertices.Index: Hashable, Vertices.Element == Vertex
    associatedtype Edges: Collection where Edges.Index: Hashable, Edges.Element == Edge
    
    var vertices: Vertices { get }
    var edges: Edges { get }
    
    func vertices(
        for edge: Edges.Index
    ) -> (source: Vertices.Index, destination: Vertices.Index)
}

public protocol DestructivelyMutableDirectedGraph: DirectedGraph {
    func removeVertex(at index: Vertices.Index)
    func removeVertices(at indices: some Sequence<Vertices.Index>)
    func removeEdge(at index: Edges.Index)
    func removeEdges(at index: some Sequence<Edges.Index>)
}

extension DirectedGraph {
    func allTopologicalSorts() -> [[Vertices.Index]] {
        var inDegree: [Vertices.Index: Int] = [:] // track in-degree of each vertex
        var adjacencyList: [Vertices.Index: [Vertices.Index]] = [:] // track adjacent vertices for each vertex
        var result: [[Vertices.Index]] = [] // all possible topological sorts
        
        // initialize in-degree and adjacency list
        for vertex in vertices.indices {
            inDegree[vertex] = 0
            adjacencyList[vertex] = []
        }
        
        for edge in edges.indices {
            let toVertex = vertices(for: edge).source
            let fromVertex = vertices(for: edge).destination
            
            inDegree[toVertex]! += 1
            adjacencyList[fromVertex]!.append(toVertex)
        }
        
        func depthFirstSearch(
            vertex: Vertices.Index,
            path: inout [Vertices.Index],
            visited: inout Set<Vertices.Index>
        ) {
            visited.insert(vertex)
            
            for neighbor in adjacencyList[vertex] ?? [] {
                if !visited.contains(neighbor) {
                    depthFirstSearch(vertex: neighbor, path: &path, visited: &visited)
                }
            }
            
            // add vertex to path and backtrack by removing it from in-degree and adjacency list
            path.append(vertex)
            inDegree[vertex] = nil
            for neighbor in adjacencyList[vertex]! {
                inDegree[neighbor]! -= 1
            }
        }
        
        for vertex in inDegree.keys.filter({ inDegree[$0] == 0 }) {
            var path: [Vertices.Index] = []
            var visited: Set<Vertices.Index> = []
            
            depthFirstSearch(vertex: vertex, path: &path, visited: &visited)
            
            result.append(path)
        }
        
        return result
    }
}
