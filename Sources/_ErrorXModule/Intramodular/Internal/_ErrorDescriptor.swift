//
// Copyright (c) Vatsal Manot
//

/// Macro-generated runtime description of an error type.
public struct _ErrorDescriptor<Failure> {
    public var catalog: _AnyErrorCodeCatalog
    public var cases: [_ErrorCaseDescriptor<Failure>]

    public init(
        catalog: _AnyErrorCodeCatalog,
        cases: [_ErrorCaseDescriptor<Failure>]
    ) {
        self.catalog = catalog
        self.cases = cases
    }

    public func `case`(
        for error: Failure
    ) -> _ErrorCaseDescriptor<Failure>? {
        cases.first { descriptor in
            descriptor.matches(error)
        }
    }
}

/// Macro-generated runtime description of one modeled error case.
public struct _ErrorCaseDescriptor<Failure> {
    public var code: _AnyErrorCode
    public var matches: @Sendable (Failure) -> Bool
    public var context: @Sendable (Failure) -> [_ErrorContextBinding]
    public var presentation: @Sendable (Failure) -> _ErrorPresentation?
    public var recoverySuggestions: @Sendable (Failure) -> [_ErrorRecoverySuggestion]
    public var underlyingError: @Sendable (Failure) -> (any Error)?
    public var failureTree: @Sendable (Failure) -> _ErrorFailureTree?

    public init(
        code: _AnyErrorCode,
        matches: @escaping @Sendable (Failure) -> Bool,
        context: @escaping @Sendable (Failure) -> [_ErrorContextBinding] = { _ in [] },
        presentation: @escaping @Sendable (Failure) -> _ErrorPresentation? = { _ in nil },
        recoverySuggestions: @escaping @Sendable (Failure) -> [_ErrorRecoverySuggestion] = { _ in [] },
        underlyingError: @escaping @Sendable (Failure) -> (any Error)? = { _ in nil },
        failureTree: @escaping @Sendable (Failure) -> _ErrorFailureTree? = { _ in nil }
    ) {
        self.code = code
        self.matches = matches
        self.context = context
        self.presentation = presentation
        self.recoverySuggestions = recoverySuggestions
        self.underlyingError = underlyingError
        self.failureTree = failureTree
    }

    public func erase(
        resolving error: Failure
    ) -> _AnyErrorCaseDescriptor {
        _AnyErrorCaseDescriptor(
            code: code,
            context: context(error),
            presentation: presentation(error),
            recoverySuggestions: recoverySuggestions(error),
            underlyingError: underlyingError(error),
            failureTree: failureTree(error)
        )
    }
}

/// Type-erased resolved descriptor for a specific error occurrence.
public struct _AnyErrorCaseDescriptor {
    public var code: _AnyErrorCode
    public var context: [_ErrorContextBinding]
    public var presentation: _ErrorPresentation?
    public var recoverySuggestions: [_ErrorRecoverySuggestion]
    public var underlyingError: (any Error)?
    public var failureTree: _ErrorFailureTree?

    public init(
        code: _AnyErrorCode,
        context: [_ErrorContextBinding],
        presentation: _ErrorPresentation?,
        recoverySuggestions: [_ErrorRecoverySuggestion],
        underlyingError: (any Error)?,
        failureTree: _ErrorFailureTree? = nil
    ) {
        self.code = code
        self.context = context
        self.presentation = presentation
        self.recoverySuggestions = recoverySuggestions
        self.underlyingError = underlyingError
        self.failureTree = failureTree
    }
}

/// Error type whose semantic model is available as a runtime descriptor.
public protocol _ErrorDescribed: Error {
    static var errorDescriptor: _ErrorDescriptor<Self> { get }

    var _errorDescriptorCase: _AnyErrorCaseDescriptor? { get }
}

extension _ErrorDescribed {
    public var _errorDescriptorCase: _AnyErrorCaseDescriptor? {
        Self.errorDescriptor.case(for: self)?.erase(resolving: self)
    }
}
