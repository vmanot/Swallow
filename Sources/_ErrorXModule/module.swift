//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@attached(member, names: named(init), named(subsystemDomainIdentifier), named(_errorCodeCatalogDomain), named(ErrorCodeIdentifier), named(_errorXDomain))
@attached(extension, conformances: _SubsystemDomain, _SubsystemDomainIdentifiable, Initiable)
public macro ErrorDomain(
    _ stableIdentifier: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorDomainMacro"
)

@attached(peer)
public macro ErrorCode(
    _ stableIdentifier: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCodeMacro"
)

@attached(peer)
public macro ErrorCode<Code: _ErrorCode>(
    _ code: Code
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCodeMacro"
)

@attached(peer)
public macro ErrorCase(
    _ stableIdentifier: StaticString,
    summary: StaticString? = nil,
    reason: StaticString? = nil,
    help: StaticString? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCaseMacro"
)

@attached(peer)
public macro ErrorCase<Code: _ErrorCode>(
    _ code: Code,
    summary: StaticString? = nil,
    reason: StaticString? = nil,
    help: StaticString? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCaseMacro"
)

@attached(memberAttribute)
@attached(member, names: named(allErrorCodes), named(errorCodeCatalogDescriptor), named(Domain), named(stableIdentifier), named(description))
@attached(extension, conformances: _ErrorCodeCatalogProtocol, _ErrorCode)
public macro ErrorCodeCatalog() = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCodeCatalogMacro"
)

@attached(accessor, names: named(get))
public macro ErrorCodeIdentifier(
    _ stableIdentifier: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCodeMacro"
)

@attached(accessor, names: named(get))
public macro ErrorContextKey(
    _ stableIdentifier: StaticString,
    privacy: _ErrorContextPrivacy = .private
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorContextKeyMacro"
)

@attached(accessor, names: named(get))
public macro ErrorScenario(
    _ stableIdentifier: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorScenarioMacro"
)

@attached(member, names: named(_ErrorModelDomain), named(Code), named(errorDescriptor), named(errorCode), named(errorContextBindings), named(errorFailureTree))
@attached(extension, conformances: Error, Hashable, _ErrorX, _ErrorDescribed, _ErrorCodeRepresentable, _ErrorContextRepresentable, _ErrorFailureTreeRepresentable)
public macro ErrorModel(
    _ stableDomainIdentifier: StaticString,
    allowUnmodeledCases: Bool = false,
    hashable: Bool = true
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorModelMacro"
)

@attached(member, names: named(_ErrorModelDomain), named(Code), named(errorDescriptor), named(errorCode), named(errorContextBindings), named(errorFailureTree))
@attached(extension, conformances: Error, Hashable, _ErrorX, _ErrorDescribed, _ErrorCodeRepresentable, _ErrorContextRepresentable, _ErrorFailureTreeRepresentable)
public macro ErrorModel<Domain>(
    domain: Domain.Type,
    allowUnmodeledCases: Bool = false,
    hashable: Bool = true
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorModelMacro"
)

@attached(peer)
public macro ErrorContext<Value>(
    _ key: _TypedErrorContextKey<Value>,
    parameter: StaticString? = nil,
    privacy: _ErrorContextPrivacy? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorContextMacro"
)

@attached(peer)
public macro ErrorContextPack(
    parameter: StaticString? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorContextPackMacro"
)

@attached(peer)
public macro ErrorSummary(
    _ summary: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorPresentationMacro"
)

@attached(peer)
public macro ErrorReason(
    _ reason: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorPresentationMacro"
)

@attached(peer)
public macro ErrorHelp(
    _ help: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorPresentationMacro"
)

@attached(peer)
public macro ErrorRecovery(
    _ title: StaticString,
    explanation: StaticString? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorRecoveryMacro"
)

@attached(peer)
public macro ErrorCause(
    parameter: StaticString? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCauseMacro"
)

@attached(peer)
public macro ErrorPrimary(
    parameter: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorPrimaryMacro"
)

@attached(peer)
public macro ErrorTranslatedFrom(
    parameter: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorTranslatedFromMacro"
)

@attached(peer)
public macro ErrorParallel(
    parameter: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorParallelMacro"
)

@attached(peer)
public macro ErrorParallelEach(
    parameter: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorParallelEachMacro"
)

@attached(peer)
public macro ErrorSuppressed(
    parameter: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorSuppressedMacro"
)

@attached(peer)
public macro ErrorCleanup(
    parameter: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCleanupMacro"
)

@attached(peer)
public macro ErrorFallbackAttempt(
    parameter: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorFallbackAttemptMacro"
)

@attached(member, names: named(init), named(subsystemDomainIdentifier), named(_errorCodeCatalogDomain), named(ErrorCodeIdentifier), named(_errorXDomain))
@attached(extension, conformances: _SubsystemDomain, _SubsystemDomainIdentifiable, Initiable)
public macro _ErrorDomain(
    _ stableIdentifier: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorDomainMacro"
)

@attached(accessor, names: named(get))
public macro _ErrorCode(
    _ stableIdentifier: StaticString
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCodeMacro"
)

@attached(memberAttribute)
@attached(member, names: named(allErrorCodes), named(errorCodeCatalogDescriptor), named(Domain), named(stableIdentifier), named(description))
@attached(extension, conformances: _ErrorCodeCatalogProtocol, _ErrorCode)
public macro _ErrorCodeCatalog() = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorCodeCatalogMacro"
)

@attached(accessor, names: named(get))
public macro _ErrorContextKey(
    _ stableIdentifier: StaticString,
    privacy: _ErrorContextPrivacy = .private
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorContextKeyMacro"
)

@attached(member, names: named(_ErrorModelDomain), named(Code), named(errorDescriptor), named(errorCode), named(errorContextBindings), named(errorFailureTree))
@attached(extension, conformances: Error, Hashable, _ErrorX, _ErrorDescribed, _ErrorCodeRepresentable, _ErrorContextRepresentable, _ErrorFailureTreeRepresentable)
public macro _ErrorModel(
    _ stableDomainIdentifier: StaticString,
    allowUnmodeledCases: Bool = false,
    hashable: Bool = true
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorModelMacro"
)

@attached(member, names: named(_ErrorModelDomain), named(Code), named(errorDescriptor), named(errorCode), named(errorContextBindings), named(errorFailureTree))
@attached(extension, conformances: Error, Hashable, _ErrorX, _ErrorDescribed, _ErrorCodeRepresentable, _ErrorContextRepresentable, _ErrorFailureTreeRepresentable)
public macro _ErrorModel<Domain>(
    domain: Domain.Type,
    allowUnmodeledCases: Bool = false,
    hashable: Bool = true
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorModelMacro"
)

@attached(peer)
public macro _ErrorContext<Value>(
    _ key: _TypedErrorContextKey<Value>,
    parameter: StaticString? = nil,
    privacy: _ErrorContextPrivacy? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorContextMacro"
)

@attached(peer)
public macro _ErrorContextPack(
    parameter: StaticString? = nil
) = #externalMacro(
    module: "_ErrorXMacrosModule",
    type: "_ErrorContextPackMacro"
)

@available(*, deprecated, renamed: "_ErrorTraits", message: "Use _ErrorTraits from _ErrorXModule.")
public typealias ErrorTraits = _ErrorTraits

public enum _module {

}
