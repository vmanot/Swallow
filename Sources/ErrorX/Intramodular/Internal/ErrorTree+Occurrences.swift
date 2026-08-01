//
// Copyright (c) Vatsal Manot
//

/// Identity and context occurrences collected from one error-tree walk.
struct _ErrorTreeOccurrences {
  struct Identity: Sendable {
    let path: [Int]
    let relationPath: [ErrorRelation.Kind]
    let error: any Error
    let identity: ErrorIdentity
  }

  struct Context: Hashable, Sendable {
    enum Owner: Hashable, Sendable {
      case error
      case relation
    }

    let path: [Int]
    let relationPath: [ErrorRelation.Kind]
    let owner: Owner
    let entry: ErrorContext.Entry
  }

  var identities: [Identity] = []
  var contexts: [Context] = []
}

extension ErrorTree {
  func _errorXOccurrences() -> _ErrorTreeOccurrences {
    typealias PendingNode = (
      tree: ErrorTree,
      path: [Int],
      relationPath: [ErrorRelation.Kind],
      incomingContext: ErrorContext
    )

    var pending: [PendingNode] = [(self, [], [], [])]
    var result = _ErrorTreeOccurrences()

    while let node = pending.popLast() {
      result.contexts.append(
        contentsOf: node.incomingContext.map { entry in
          .init(
            path: node.path,
            relationPath: node.relationPath,
            owner: .relation,
            entry: entry
          )
        }
      )

      let base = node.tree.root._errorXBase
      let descriptor = (base as? any _ModeledError)?._resolvedErrorDescriptor

      if let identity = base._errorXIdentity(resolvedDescriptor: descriptor) {
        result.identities.append(
          .init(
            path: node.path,
            relationPath: node.relationPath,
            error: base,
            identity: identity
          )
        )
      }

      let entries: ErrorContext

      if let descriptor {
        entries = descriptor.context
      } else if let error = base as? any ErrorContextProviding {
        entries = error.errorContext
      } else {
        entries = []
      }

      result.contexts.append(
        contentsOf: entries.map { entry in
          .init(
            path: node.path,
            relationPath: node.relationPath,
            owner: .error,
            entry: entry
          )
        }
      )

      for index in node.tree.relations.indices.reversed() {
        let relation = node.tree.relations[index]
        let path = node.path + [index]
        let relationPath = node.relationPath + [relation.kind]

        pending.append(
          (
            tree: relation.subtree,
            path: path,
            relationPath: relationPath,
            incomingContext: relation.context
          )
        )
      }
    }

    return result
  }
}
