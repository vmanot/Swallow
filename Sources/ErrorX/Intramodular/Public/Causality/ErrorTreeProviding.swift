//
// Copyright (c) Vatsal Manot
//

/// Supplies the complete composition tree for an error.
public protocol ErrorTreeProviding: Error {
  /// The complete error tree rooted at this error.
  var errorTree: ErrorTree { get }
}
