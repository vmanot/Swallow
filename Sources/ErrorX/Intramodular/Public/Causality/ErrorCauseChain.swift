//
// Copyright (c) Vatsal Manot
//

import Foundation

/// The primary causal chain of an error, ordered from the outer error to its root cause.
///
/// Each step follows a direct ``ErrorRelation/Kind/cause`` or, when no direct
/// cause exists, a ``ErrorRelation/Kind/translatedFrom`` relationship.
public struct ErrorCauseChain: Sendable, RandomAccessCollection, CustomStringConvertible,
  CustomDebugStringConvertible
{
  public typealias Element = any Error
  public typealias Index = Int

  private let storage: [any Error]

  public var startIndex: Index {
    storage.startIndex
  }

  public var endIndex: Index {
    storage.endIndex
  }

  /// Discovers the primary causal chain beginning with `error`.
  public init(_ error: some Error) {
    let base = error._errorXBase

    if let provider = base as? any ErrorTreeProviding {
      storage = Self._makeErrors(from: provider.errorTree)
    } else if let tree = (base as? any _ModeledError)?._resolvedErrorDescriptor?.errorTree {
      storage = Self._makeErrors(from: tree)
    } else {
      storage = Self._makeErrors(from: error)
    }
  }

  init(errorTree: ErrorTree) {
    storage = Self._makeErrors(from: errorTree)
  }

  public subscript(position: Index) -> any Error {
    storage[position]
  }

  /// Error identities or type names, ordered from the outer error inward.
  public var description: String {
    map(Self._description(of:)).joined(separator: " -> ")
  }

  /// A structural description of the primary causal chain.
  public var debugDescription: String {
    "ErrorCauseChain([\(map(Self._description(of:)).joined(separator: ", "))])"
  }
}

extension Error {
  var _errorXCauseChain: ErrorCauseChain {
    ErrorCauseChain(self)
  }
}

extension ErrorCauseChain {
  private static func _description(of error: any Error) -> String {
    error._errorXIdentity?.description
      ?? String(reflecting: Swift.type(of: error._errorXBase))
  }

  private static func _makeErrors(from errorTree: ErrorTree) -> [any Error] {
    var errors: [any Error] = []
    var current = errorTree

    while true {
      errors.append(current.root)

      let predecessor =
        current.relations.first(where: { $0.kind == .cause })
        ?? current.relations.first(where: { $0.kind == .translatedFrom })

      guard let predecessor else {
        break
      }

      current = predecessor.subtree
    }

    return errors
  }

  private static func _makeErrors(from error: some Error) -> [any Error] {
    var result: [any Error] = []
    var visitedClassErrors: Set<ObjectIdentifier> = []
    var current: (any Error)? = error

    while let error = current, result.count < _ErrorXTraversalLimit.maximumDepth {
      let base = error._errorXBase

      if let objectIdentifier = base._errorXObjectIdentifier {
        guard visitedClassErrors.insert(objectIdentifier).inserted else {
          break
        }
      }

      result.append(base)

      if let descriptorCause = (base as? any _ModeledError)?._resolvedErrorDescriptor?
        .underlyingError
      {
        current = descriptorCause
      } else if let providedCause = (base as? any ErrorCauseProviding)?.underlyingError {
        current = providedCause
      } else if let cocoaCause = base._errorXCocoaUserInfo?[NSUnderlyingErrorKey] as? any Error {
        current = cocoaCause
      } else {
        current = nil
      }
    }

    return result
  }
}
