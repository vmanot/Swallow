//
// Copyright (c) Vatsal Manot
//

/// Macro-generated runtime description of an error type.
public struct _ErrorDescriptor<Failure> {
  private let _resolve: @Sendable (Failure) -> _ResolvedErrorDescriptor?

  /// Creates a descriptor backed by `resolve`.
  public init(
    resolve: @escaping @Sendable (Failure) -> _ResolvedErrorDescriptor?
  ) {
    self._resolve = resolve
  }

  /// Resolves the modeled information for `error`.
  public func resolve(
    _ error: Failure
  ) -> _ResolvedErrorDescriptor? {
    _resolve(error)
  }
}
