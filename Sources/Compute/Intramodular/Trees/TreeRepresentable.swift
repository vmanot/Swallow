//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A type that can be represented as a tree.
public protocol TreeRepresentable: Identifiable {
    associatedtype TreeRepresentation: RecursiveTreeProtocol
    
    init(treeRepresentation: TreeRepresentation)
}
