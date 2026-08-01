//
// Copyright (c) Vatsal Manot
//

/// Traversal bounds shared by ErrorX's cycle-safe projections.
enum _ErrorXTraversalLimit {
  static let maximumDepth = 64
}

extension Error {
  var _errorXBase: any Error {
    var current: any Error = self
    var visitedObjects: Set<ObjectIdentifier> = []

    for _ in 0..<_ErrorXTraversalLimit.maximumDepth {
      guard let wrapper = current as? any TransparentError else {
        return current
      }

      if let identifier = current._errorXObjectIdentifier {
        guard visitedObjects.insert(identifier).inserted else {
          return current
        }
      }

      current = wrapper.wrappedError
    }

    return current
  }

  var _errorXObjectIdentifier: ObjectIdentifier? {
    // `Mirror.displayStyle` can be replaced by `CustomReflectable`, so it
    // cannot reliably distinguish reference errors from boxed values.
    guard Swift.type(of: self) is AnyClass else {
      return nil
    }

    return ObjectIdentifier(self as AnyObject)
  }
}
