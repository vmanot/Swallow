//
// Copyright (c) Vatsal Manot
//

/// Attaches an associated value to the modeled case's context.
@attached(peer)
public macro ErrorContext<Value: ErrorContextValue>(
  _ key: ErrorContext.Key<Value>,
  from associatedValue: StaticString? = nil,
  privacy: ErrorContext.Privacy? = nil
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )

/// Attaches local context without requiring a reusable typed key.
@attached(peer)
public macro ErrorContext(
  _ key: StaticString,
  from associatedValue: StaticString? = nil,
  privacy: ErrorContext.Privacy = .private
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )

/// Includes context supplied by an associated ``ErrorContextProviding`` value.
@attached(peer)
public macro ErrorContext(
  contentsOf associatedValue: StaticString
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMarkerMacro"
  )
