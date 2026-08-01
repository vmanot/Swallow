//
// Copyright (c) Vatsal Manot
//

import Foundation

extension Error {
  /// Returns whether this value itself is a recognized cancellation signal.
  var _errorXIsCancellation: Bool {
    if self is CancellationError {
      return true
    }

    if let error = self as? URLError {
      return error.code == .cancelled || error.code == .userCancelledAuthentication
    }

    if let error = self as? CocoaError {
      return error.code == .userCancelled || error.code == .migrationCancelled
    }

    if let error = self as? POSIXError {
      return error.code == .ECANCELED
    }

    guard let error = _errorXNativeNSError else {
      return false
    }

    switch error.domain {
    case NSURLErrorDomain:
      return error.code == URLError.Code.cancelled.rawValue
        || error.code == URLError.Code.userCancelledAuthentication.rawValue
    case NSCocoaErrorDomain:
      return error.code == CocoaError.Code.userCancelled.rawValue
        || error.code == CocoaError.Code.migrationCancelled.rawValue
    case NSPOSIXErrorDomain:
      return error.code == POSIXErrorCode.ECANCELED.rawValue
    default:
      return false
    }
  }
}
