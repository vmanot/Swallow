//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TryMacroOption: Hashable, Sendable {
    public static let optimistic = Self()
}

@freestanding(expression)
public macro `try`<T>(_ options: TryMacroOption..., _ fn: () throws -> T) -> T? = #externalMacro(
    module: "SwallowMacros",
    type: "TryMacro"
)

@freestanding(expression)
public macro `try`<T>(_ options: TryMacroOption..., _ fn: () throws -> T?) -> T? = #externalMacro(
    module: "SwallowMacros",
    type: "TryMacro"
)

@freestanding(expression)
public macro `try`<T>(_ options: TryMacroOption..., _ fn: () async throws -> T) -> T? = #externalMacro(
    module: "SwallowMacros",
    type: "TryAwaitMacro"
)

@freestanding(expression)
public macro `try`<T>(_ options: TryMacroOption..., _ fn: () async throws -> T?) -> T? = #externalMacro(
    module: "SwallowMacros",
    type: "TryAwaitMacro"
)
