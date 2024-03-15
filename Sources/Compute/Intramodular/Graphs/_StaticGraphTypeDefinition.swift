//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _StaticGraphNodeDefinition {
    associatedtype Value
}

public protocol _StaticGraphTypeDefinition {
    associatedtype Node: _StaticGraphNodeDefinition
    associatedtype Edge: Hashable
}

// MARK: - Supplementary

public struct _SomeStaticGraphNodeDefinition<ValueType>: _StaticGraphNodeDefinition {
    public typealias Value = ValueType
}
