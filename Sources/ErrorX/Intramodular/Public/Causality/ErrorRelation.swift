//
// Copyright (c) Vatsal Manot
//

/// A directed relationship from one error to another error tree.
public struct ErrorRelation: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  /// The semantic role of a related error.
  public enum Kind: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// The error that directly caused the source error.
    case cause

    /// The lower-level error whose meaning was translated into the source error.
    case translatedFrom

    /// One failed component of an aggregate operation.
    case component

    /// A failure produced by a concurrent sibling task.
    case concurrent

    /// A secondary failure that did not replace the primary failure.
    case suppressed

    /// A failure produced while cleaning up after another operation.
    case cleanup

    /// A failure produced by a fallback attempt.
    case fallback

    /// A stable diagnostic name for the relationship.
    public var description: String {
      switch self {
      case .cause:
        return "cause"
      case .translatedFrom:
        return "translated-from"
      case .component:
        return "component"
      case .concurrent:
        return "concurrent"
      case .suppressed:
        return "suppressed"
      case .cleanup:
        return "cleanup"
      case .fallback:
        return "fallback"
      }
    }

    /// A source-like description of the relationship kind.
    public var debugDescription: String {
      switch self {
      case .translatedFrom:
        return ".translatedFrom"
      default:
        return ".\(description)"
      }
    }
  }

  /// The semantic role of the related error.
  public let kind: Kind

  /// The related error and any relationships rooted at it.
  public let subtree: ErrorTree

  /// Context that describes this relationship rather than either error.
  ///
  /// For example, a task-group aggregate can attach a stable task identifier
  /// or input index to each ``Kind/concurrent`` relation.
  public let context: ErrorContext

  /// Creates a relationship to `subtree`.
  public init(
    _ kind: Kind,
    to subtree: ErrorTree,
    context: ErrorContext = []
  ) {
    self.kind = kind
    self.subtree = subtree
    self.context = context
  }

  /// Creates a relationship to `error`, preserving any structure it exposes.
  ///
  /// Structure supplied by ``ErrorTreeProviding``, `@ErrorModel`, and Cocoa
  /// underlying-error keys becomes the relationship's ``subtree``.
  public init<Failure: Error>(
    _ kind: Kind,
    to error: Failure,
    context: ErrorContext = []
  ) {
    self.init(kind, to: ErrorTree._errorXDiscovering(error), context: context)
  }

  /// The relationship kind and related root error.
  public var description: String {
    "\(kind.description): \(subtree.description)"
  }

  /// A structural description of the relationship and its subtree.
  public var debugDescription: String {
    "ErrorRelation(\(kind.debugDescription), to: \(subtree.debugDescription), context: \(context.debugDescription))"
  }
}
