//
// Copyright (c) Vatsal Manot
//

/// A type-erased ``ErrorCode``.
public struct AnyErrorCode: Hashable, Sendable, CustomStringConvertible,
  CustomDebugStringConvertible
{
  /// The underlying code.
  public let base: any ErrorCode

  /// The domain in which the code is unique.
  public var domain: String {
    Swift.type(of: base).domain
  }

  /// The code's stable identifier within ``domain``.
  public var identifier: String {
    base.identifier
  }

  /// The domain-and-code identity.
  public var identity: ErrorIdentity {
    base.identity
  }

  /// The fully qualified identity of the code.
  public var description: String {
    identity.description
  }

  /// A structural description of the erased code.
  public var debugDescription: String {
    "AnyErrorCode(\(identity.debugDescription), base: \(String(reflecting: Swift.type(of: base))))"
  }

  /// Erases the concrete type of `base`.
  public init<Code: ErrorCode>(_ base: Code) {
    self.base = base
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.identity == rhs.identity
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(identity)
  }
}
