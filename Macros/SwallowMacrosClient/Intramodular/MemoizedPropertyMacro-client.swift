//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(accessor)
@attached(peer, names: prefixed(_memoized_))
public macro MemoizedProperty<T, U, V>(_ keyPath: KeyPath<T, U>, value: (T) -> V) = #externalMacro(
    module: "SwallowMacros",
    type: "MemoizedPropertyMacro"
)
