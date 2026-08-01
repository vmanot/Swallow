//
// Copyright (c) Vatsal Manot
//

import Foundation

/// Makes a normalized report directly usable with Cocoa and SwiftUI error-presentation APIs.
extension ErrorReport: LocalizedError {
  public var errorDescription: String? {
    presentation?.message
  }

  public var failureReason: String? {
    presentation?.failureReason
  }

  public var recoverySuggestion: String? {
    recoveryOptions.lazy.compactMap(\.explanation).first
  }

  public var helpAnchor: String? {
    presentation?.helpAnchor
  }
}
