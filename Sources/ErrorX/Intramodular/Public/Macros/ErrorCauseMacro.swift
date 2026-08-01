//
// Copyright (c) Vatsal Manot
//

/// Marks one associated error as the primary cause of the modeled case.
@attached(peer)
public macro ErrorCause(
  _ associatedValue: StaticString? = nil
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )
