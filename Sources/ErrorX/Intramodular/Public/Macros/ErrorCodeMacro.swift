//
// Copyright (c) Vatsal Manot
//

// A presentation argument may carry placeholders naming the case's
// associated values. Write them in braces:
//
//     @ErrorCode(message: "Cannot copy sources for {module}.")
//     case unavailableModuleSourceDirectory(module: String)
//
// `@ErrorModel` rewrites each placeholder onto the matching associated value
// when it synthesizes the per-case message. `{{` and `}}` produce literal
// braces; `{0}` references an unlabeled value by position; `{url.path}`
// follows a name with an accessor chain.
//
// For an arbitrary expression, the interpolation spelling is also accepted
// inside a *raw* literal, where Swift leaves `\(` inert instead of
// type-checking it against the attribute's scope:
//
//     @ErrorCode(message: #"Cannot copy \(url.path(percentEncoded: false))."#)

/// Assigns a stable code and optional presentation to an error case.
@attached(peer)
public macro ErrorCode(
  _ identifier: StaticString,
  message: StaticString? = nil,
  failureReason: StaticString? = nil,
  helpAnchor: StaticString? = nil
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )

/// Assigns a catalog code and optional presentation to an error case.
@attached(peer)
public macro ErrorCode<Code: ErrorCode>(
  _ code: Code,
  message: StaticString? = nil,
  failureReason: StaticString? = nil,
  helpAnchor: StaticString? = nil
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )

/// Marks an error case as modeled, using the case's own name as its stable code.
@attached(peer)
public macro ErrorCode(
  message: StaticString? = nil,
  failureReason: StaticString? = nil,
  helpAnchor: StaticString? = nil
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )
