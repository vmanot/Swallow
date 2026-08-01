//
// Copyright (c) Vatsal Manot
//

/// A value that can be stored in and recovered from ``ErrorContext``.
public protocol ErrorContextValue: Hashable, Sendable {
  /// The type-erased value stored in an ``ErrorContext``.
  var errorContextValue: ErrorContext.Value { get }

  /// Creates a value from its type-erased representation.
  init?(errorContextValue: ErrorContext.Value)
}

extension String: ErrorContextValue {
  public var errorContextValue: ErrorContext.Value {
    .string(self)
  }

  public init?(errorContextValue: ErrorContext.Value) {
    guard case .string(let value) = errorContextValue else {
      return nil
    }

    self = value
  }
}

extension Int: ErrorContextValue {
  public var errorContextValue: ErrorContext.Value {
    .integer(self)
  }

  public init?(errorContextValue: ErrorContext.Value) {
    guard case .integer(let value) = errorContextValue else {
      return nil
    }

    self = value
  }
}

extension Bool: ErrorContextValue {
  public var errorContextValue: ErrorContext.Value {
    .boolean(self)
  }

  public init?(errorContextValue: ErrorContext.Value) {
    guard case .boolean(let value) = errorContextValue else {
      return nil
    }

    self = value
  }
}

extension Double: ErrorContextValue {
  public var errorContextValue: ErrorContext.Value {
    .double(self)
  }

  public init?(errorContextValue: ErrorContext.Value) {
    guard case .double(let value) = errorContextValue else {
      return nil
    }

    self = value
  }
}
