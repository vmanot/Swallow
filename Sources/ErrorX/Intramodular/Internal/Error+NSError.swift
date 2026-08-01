//
// Copyright (c) Vatsal Manot
//

import Foundation

extension Error {
  /// Returns an `NSError` only when the thrown value is natively an `NSError`.
  var _errorXNativeNSError: NSError? {
    guard Swift.type(of: self) is NSError.Type else {
      return nil
    }

    return self as NSError
  }

  /// Returns authored Cocoa user info without bridging arbitrary Swift errors.
  var _errorXCocoaUserInfo: [String: Any]? {
    if let error = _errorXNativeNSError {
      return error.userInfo
    }

    return (self as? any CustomNSError)?.errorUserInfo
  }

  /// Returns Foundation's explicitly modeled aggregate causes, when present.
  var _errorXCocoaMultipleUnderlyingErrors: [any Swift.Error] {
    guard #available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *),
      let values = _errorXCocoaUserInfo?[NSMultipleUnderlyingErrorsKey] as? [Any]
    else {
      return []
    }

    return values.compactMap { value in
      value as? any Swift.Error
    }
  }

  /// Casts without allowing Swift's unconditional `Error`-to-`NSError` bridge
  /// to turn every Swift error into a false native-`NSError` match.
  func _errorXCast<Failure: Error>(
    to type: Failure.Type
  ) -> Failure? {
    if type == NSError.self {
      return _errorXNativeNSError as? Failure
    }

    return self as? Failure
  }
}
