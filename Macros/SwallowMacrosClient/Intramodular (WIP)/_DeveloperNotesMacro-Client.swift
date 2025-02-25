//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

/// An API marker for a method that is currently unused.
///
/// "Currently unused" means that it is not being meaningfully utilized anywhere in the codebase.
@attached(peer)
public macro __unused_method() = #externalMacro(
    module: "SwallowMacros",
    type: "_DeveloperNotesMacro"
)
