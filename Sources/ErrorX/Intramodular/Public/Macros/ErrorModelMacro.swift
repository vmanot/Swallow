//
// Copyright (c) Vatsal Manot
//

/// Synthesizes error modeling for an enum whose cases all use one code catalog.
@attached(member, names: named(Code), named(_errorDescriptor))
@attached(extension, conformances: Error, _ModeledError)
public macro ErrorModel(
  allowingUnmodeledCases: Bool = false
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMacro"
  )

/// Synthesizes error modeling for an enum in `domain`.
@attached(member, names: named(Code), named(_errorDescriptor))
@attached(extension, conformances: Error, _ModeledError)
public macro ErrorModel(
  domain: StaticString,
  allowingUnmodeledCases: Bool = false
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMacro"
  )

/// Synthesizes error modeling using `catalog` as the domain's code vocabulary.
@attached(member, names: named(Code), named(_errorDescriptor))
@attached(extension, conformances: Error, _ModeledError)
public macro ErrorModel<Catalog: ErrorCode & CaseIterable>(
  catalog: Catalog.Type,
  allowingUnmodeledCases: Bool = false
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorModelMacro"
  )
