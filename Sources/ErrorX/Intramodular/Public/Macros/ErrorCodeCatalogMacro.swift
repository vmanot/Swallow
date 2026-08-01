//
// Copyright (c) Vatsal Manot
//

/// Declares an enum as the complete set of codes for an error domain.
@attached(member, names: named(domain), named(allCases), named(identifier))
@attached(extension, conformances: ErrorCode, CaseIterable)
public macro ErrorCodeCatalog(
  domain: StaticString
) =
  #externalMacro(
    module: "ErrorXMacros",
    type: "ErrorCodeCatalogMacro"
  )
