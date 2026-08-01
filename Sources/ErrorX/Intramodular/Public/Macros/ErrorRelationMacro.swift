//
// Copyright (c) Vatsal Manot
//

/// Relates the modeled case to one associated error.
@attached(peer)
public macro ErrorRelation(
  _ kind: ErrorRelation.Kind,
  error associatedValue: StaticString
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )

/// Relates the modeled case to every error in an associated collection.
@attached(peer)
public macro ErrorRelation(
  _ kind: ErrorRelation.Kind,
  errors associatedValue: StaticString
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )
