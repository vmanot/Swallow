//
// Copyright (c) Vatsal Manot
//

/// A rooted snapshot of an error and the failures related to it.
///
/// A tree always has one root error. Relationships are directed edges from
/// that root to other error trees. This keeps the error being reported
/// distinct from its causes, aggregate components, and secondary failures.
public struct ErrorTree: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  /// The error at the root of this tree.
  public let root: any Error

  /// Relationships from ``root`` to other error trees, in source order.
  public let relations: [ErrorRelation]

  /// Creates a tree rooted at `error`.
  ///
  /// Transparent wrappers are omitted from the stored root.
  public init(
    _ error: some Error,
    relations: [ErrorRelation] = []
  ) {
    self.root = error._errorXBase
    self.relations = relations
  }

  init(
    root: any Error,
    relations: [ErrorRelation] = []
  ) {
    self.root = root
    self.relations = relations
  }

  init(causeChain: ErrorCauseChain) {
    guard var tree = causeChain.last.map({ Self(root: $0) }) else {
      preconditionFailure("An error cause chain cannot be empty.")
    }

    for error in causeChain.dropLast().reversed() {
      tree = Self(
        root: error,
        relations: [ErrorRelation(.cause, to: tree)]
      )
    }

    self = tree
  }

  /// A concise label for the root error.
  public var description: String {
    if let identity = root._errorXIdentity {
      return identity.description
    }

    return String(reflecting: Swift.type(of: root))
  }

  /// A structural description of the complete tree.
  public var debugDescription: String {
    let relations = relations.map(\.debugDescription).joined(separator: ", ")
    return "ErrorTree(root: \(description), relations: [\(relations)])"
  }
}
