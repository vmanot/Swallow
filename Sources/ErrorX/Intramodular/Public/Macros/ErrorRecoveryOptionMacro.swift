//
// Copyright (c) Vatsal Manot
//

/// Adds a recovery option to a modeled error case.
@attached(peer)
public macro ErrorRecoveryOption(
  _ title: StaticString,
  explanation: StaticString? = nil
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )
