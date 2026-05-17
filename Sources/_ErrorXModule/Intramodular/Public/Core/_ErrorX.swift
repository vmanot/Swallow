//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Swift's `Error` protocol is too basic.
///
/// Relevant:
/// - https://forums.swift.org/t/pitch-consistent-bridging-for-nserrors-at-the-language-boundary/2482
///   Swift-native payloads, useful presentation, and NSError interop force
///   bad tradeoffs; string domains and integer codes drift from typed errors.
/// - https://github.com/swiftlang/swift-evolution/blob/main/proposals/0112-nserror-bridging.md
///   Localization, recovery, userInfo, and Cocoa interop were split into
///   protocols, but Swift still got no real native error object model.
/// - https://forums.swift.org/t/amendment-to-se-0112-default-values-for-errordomain-and-errorcode/3705
///   `CustomNSError` makes stable identity boilerplate; treating domain/code
///   as ObjC-only glue throws away useful Swift diagnostic identity.
/// - https://forums.swift.org/t/add-underlyingerror-error-property-to-error/49590
///   No standard cause chain means large apps invent incompatible wrappers
///   and lose production debugging context across module boundaries.
/// - https://forums.swift.org/t/precise-error-typing-in-swift/52045
///   Precise errors help locally, but become a blunt instrument when every
///   layer must mint wrapper enums, catch-all cases, and brittle mappings.
/// - https://forums.swift.org/t/error-to-nserror-conversion/74210
///   Associated-value errors can decay across XPC/NSError into domain/code
///   sludge with `(null)` text unless every boundary is hand-modeled.
/// - https://forums.swift.org/t/proposal-slg-0003-standardized-error-metadata-via-logger-convenience/84518
///   Logging wants standard error metadata because `any Error` exposes almost
///   nothing; backend-specific casting is not an error model.
/// - https://nonstrict.eu/blog/2026/the-four-audiences-of-swift-errors/
///   User text, catch identity, debugging, and monitoring are different
///   audiences; auto-bridged NSError codes are unstable observability keys.
/// - https://nonstrict.eu/blog/2026/designing-swift-errors-for-an-sdk/
///   SDK errors are API contracts: stable code identity and rich occurrence
///   context need separate, evolvable shapes.
/// - https://fline.dev/blog/swift-6-typed-throws-error-chains/
///   Typed throws helps type flow, but layering still needs explicit chains
///   that preserve original identity and propagation context.
/// - https://docs.vapor.codes/de/basics/errors/
///   Framework-grade errors need identifiers, source, causes, stacks, possible
///   causes, and suggested fixes beyond `LocalizedError`.
/// - https://doc.rust-lang.org/std/error/trait.Error.html
///   Rust at least standardizes causal `source()` and typed context providers;
///   Swift has no equivalent contract over arbitrary errors.
/// - https://docs.rs/miette/latest/miette/trait.Diagnostic.html
///   Mature diagnostics model stable codes, severity, help, related errors,
///   source labels, and documentation URLs as structured data.
/// - https://effect-ts.github.io/effect/effect/Cause.ts.html
///   Modern effect systems model expected failure, defects, interruption, and
///   sequential/parallel cause trees; one erased thrown value is not enough.
public protocol _ErrorX: _ErrorTraitsBuilding, Swift.Error {
    var traits: _ErrorTraits { get }

    init?(_catchAll error: AnyError) throws
}

/// Domain-scoped error that can wrap arbitrary lower-level failures.
public protocol _SubsystemDomainError: _ErrorX {
    init(_catchAll error: AnyError)
}

// MARK: - Implementation

extension _ErrorX {
    public var traits: _ErrorTraits {
        []
    }

    @_transparent
    public init?(_catchAll error: AnyError) throws {
        throw Never.Reason.unavailable
    }

    @_transparent
    public init?(_catchAll error: any Error) throws {
        try self.init(_catchAll: .init(erasing: error))
    }
}

// MARK: - API

extension _ErrorX {
    @_transparent
    public static func _catchAll(_ error: Never.Reason) -> Self! {
        try? Self(_catchAll: error)
    }
}

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    context: _ErrorWrappingContext,
    operation: () throws -> R
) throws -> R {
    do {
        let result = Result(catching: { try operation() })

        if case .failure(let error) = result {
            runtimeIssue(error)
        }

        return try result.get()
    } catch(let error) {
        if let error = error as? E {
            throw error
        } else {
            let wrappedError: Error

            if let wrapperType = E.self as? any _ErrorWrappingRepresentable.Type {
                wrappedError = wrapperType.init(
                    wrapping: AnyError(erasing: error),
                    context: context
                )
            } else {
                do {
                    wrappedError = try E(_catchAll: error).unwrap()
                } catch(let wrappingError) {
                    assertionFailure(wrappingError)

                    throw error
                }
            }

            throw wrappedError
        }
    }
}

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    operation: () throws -> R
) throws -> R {
    try _withErrorType(
        type,
        context: .init(),
        operation: operation
    )
}

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    location: SourceCodeLocation,
    operation: () throws -> R
) throws -> R {
    try _withErrorType(
        type,
        context: .init(location: location),
        operation: operation
    )
}

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    operation: () async throws -> R
) async throws -> R {
    try await _withErrorType(
        type,
        context: .init(),
        operation: operation
    )
}

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    context: _ErrorWrappingContext,
    operation: () async throws -> R
) async throws -> R {
    let result = await Result {
        try await operation()
    }

    return try _withErrorType(type, context: context) {
        try result.get()
    }
}

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    location: SourceCodeLocation,
    operation: () async throws -> R
) async throws -> R {
    try await _withErrorType(
        type,
        context: .init(location: location),
        operation: operation
    )
}

// MARK: - Conformees

extension AnyError: _ErrorX {
    public var traits: _ErrorTraits {
        (base as? (any _ErrorX))?.traits ?? []
    }

    @_transparent
    public init?(_catchAll error: AnyError) throws {
        self.init(erasing: error)
    }
}
