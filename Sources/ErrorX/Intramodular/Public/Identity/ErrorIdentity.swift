//
// Copyright (c) Vatsal Manot
//

import Foundation

/// The stable domain-and-code identity of an error occurrence.
public struct ErrorIdentity: Hashable, Sendable, CustomStringConvertible,
  CustomDebugStringConvertible
{
  /// The namespace in which ``code`` is unique.
  public let domain: String

  /// The stable code within ``domain``.
  public let code: String

  /// The domain and code joined by a period.
  public var description: String {
    "\(domain).\(code)"
  }

  /// A structural description of the identity.
  public var debugDescription: String {
    "ErrorIdentity(domain: \(String(reflecting: domain)), code: \(String(reflecting: code)))"
  }

  /// Creates an identity from a domain and code.
  public init(
    domain: String,
    code: String
  ) {
    self.domain = domain
    self.code = code
  }

  /// Creates the identity exposed by `error`, or returns `nil` when it has none.
  public init?(_ error: some Error) {
    guard let identity = error._errorXIdentity else {
      return nil
    }

    self = identity
  }
}

extension Error {
  var _errorXIdentity: ErrorIdentity? {
    let base = _errorXBase
    let descriptor = (base as? any _ModeledError)?._resolvedErrorDescriptor

    return base._errorXIdentity(resolvedDescriptor: descriptor)
  }

  func _errorXIdentity(
    resolvedDescriptor: _ResolvedErrorDescriptor?
  ) -> ErrorIdentity? {
    if let identity = _errorXCode(resolvedDescriptor: resolvedDescriptor)?.identity {
      return identity
    }

    if let error = _errorXNativeNSError {
      return ErrorIdentity(domain: error.domain, code: String(error.code))
    }

    if let error = self as? any CustomNSError {
      return ErrorIdentity(domain: type(of: error).errorDomain, code: String(error.errorCode))
    }

    return nil
  }
}
