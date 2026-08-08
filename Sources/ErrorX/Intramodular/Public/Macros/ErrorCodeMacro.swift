//
// Copyright (c) Vatsal Manot
//

// A presentation argument may carry `\(...)` placeholders naming the case's
// associated values. Swift type-checks these attribute arguments, so the
// placeholders have to sit inside an *inert* literal — write a raw literal,
// `#"Cannot copy sources for \(module)."#` — and `@ErrorModel` rewrites each
// placeholder onto the matching associated value when it synthesizes the
// per-case message.

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
