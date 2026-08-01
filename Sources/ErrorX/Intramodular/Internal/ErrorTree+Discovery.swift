//
// Copyright (c) Vatsal Manot
//

import Foundation

private enum _ErrorTreeDiscoveryContext {
  @TaskLocal static var objectPath: Set<ObjectIdentifier> = []
}

extension ErrorTree {
  /// Discovers the complete structure exposed by `error`.
  static func _errorXDiscovering(_ error: any Swift.Error) -> Self {
    let base = error._errorXBase

    guard let identifier = base._errorXObjectIdentifier else {
      return _errorXDiscoveringBase(base)
    }

    guard !_ErrorTreeDiscoveryContext.objectPath.contains(identifier) else {
      return Self(base)
    }

    var objectPath = _ErrorTreeDiscoveryContext.objectPath
    objectPath.insert(identifier)

    return _ErrorTreeDiscoveryContext.$objectPath.withValue(objectPath) {
      _errorXDiscoveringBase(base)
    }
  }

  private static func _errorXDiscoveringBase(_ base: any Swift.Error) -> Self {
    if let provider = base as? any ErrorTreeProviding {
      return provider.errorTree
    }

    if let tree = (base as? any _ModeledError)?._resolvedErrorDescriptor?.errorTree {
      return tree
    }

    let cocoaErrors = base._errorXCocoaMultipleUnderlyingErrors

    if !cocoaErrors.isEmpty {
      var relations: [ErrorRelation] = []

      if let primary = base._errorXCocoaUserInfo?[NSUnderlyingErrorKey] as? any Swift.Error {
        relations.append(ErrorRelation(.cause, to: primary))
      }

      relations.append(
        contentsOf: cocoaErrors.map { error in
          ErrorRelation(.component, to: error)
        }
      )

      return Self(base, relations: relations)
    }

    return Self(causeChain: base._errorXCauseChain)
  }
}
