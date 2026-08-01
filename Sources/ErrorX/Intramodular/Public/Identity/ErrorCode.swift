//
// Copyright (c) Vatsal Manot
//

/// A durable identifier within an error domain.
public protocol ErrorCode: Hashable, Sendable, CustomStringConvertible,
  CustomDebugStringConvertible
{
  /// The namespace in which this code is unique.
  static var domain: String { get }

  /// The stable identifier of this code within ``domain``.
  var identifier: String { get }
}

extension ErrorCode {
  /// The domain-and-code identity.
  public var identity: ErrorIdentity {
    ErrorIdentity(domain: Self.domain, code: identifier)
  }

  /// The code's stable identifier.
  public var description: String {
    identifier
  }

  /// A structural description containing the concrete code type and identifier.
  public var debugDescription: String {
    "\(String(reflecting: Self.self))(\(String(reflecting: identifier)))"
  }
}

extension ErrorCode where Self: RawRepresentable, RawValue == String {
  public var identifier: String {
    rawValue
  }
}
