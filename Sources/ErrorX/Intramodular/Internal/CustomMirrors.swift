//
// Copyright (c) Vatsal Manot
//

extension _ResolvedErrorDescriptor: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(
      self,
      children: [
        "code": code,
        "context": context,
        "presentation": presentation as Any,
        "recoveryOptions": recoveryOptions,
        "underlyingError": underlyingError as Any,
        "errorTree": errorTree as Any,
      ],
      displayStyle: .struct
    )
  }
}

extension AnyErrorCode: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(
      self,
      children: [
        "identifier": identifier,
        "identity": identity,
        "domain": domain,
        "base": base,
      ],
      displayStyle: .struct
    )
  }
}

extension ErrorIdentity: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(
      self,
      children: [
        "domain": domain,
        "code": code,
      ],
      displayStyle: .struct
    )
  }
}

extension ErrorContext: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .collection)
  }
}

extension ErrorContext.Entry: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(
      self,
      children: [
        "key": key,
        "value": value,
        "privacy": privacy,
      ],
      displayStyle: .struct
    )
  }
}

extension ErrorCauseChain: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .collection)
  }
}

extension ErrorTree: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(
      self,
      children: [
        "root": root,
        "relations": relations,
      ],
      displayStyle: .struct
    )
  }
}

extension ErrorRelation: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(
      self,
      children: [
        "kind": kind,
        "subtree": subtree,
        "context": context,
      ],
      displayStyle: .struct
    )
  }
}

extension ErrorScenario: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(self, children: ["identifier": identifier], displayStyle: .struct)
  }
}

extension ErrorReport: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(
      self,
      children: [
        "error": error,
        "causeChain": causeChain,
        "errorTree": errorTree,
        "primaryIdentity": primaryIdentity as Any,
        "causeIdentities": causeIdentities,
        "identities": identities,
        "identityOccurrences": identityOccurrences,
        "contextOccurrences": contextOccurrences,
        "presentation": presentation as Any,
        "recoveryOptions": recoveryOptions,
        "context": context,
        "observation": observation,
      ],
      displayStyle: .struct
    )
  }
}
