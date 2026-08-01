//
// Copyright (c) Vatsal Manot
//

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
