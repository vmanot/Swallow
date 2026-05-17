//
// Copyright (c) Vatsal Manot
//

extension _ErrorDescriptor: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "catalog": catalog,
                "cases": cases,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorCaseDescriptor: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "code": code,
            ],
            displayStyle: .struct
        )
    }
}

extension _AnyErrorCaseDescriptor: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "code": code,
                "context": context,
                "presentation": presentation as Any,
                "recoverySuggestions": recoverySuggestions,
                "underlyingError": underlyingError as Any,
                "failureTree": failureTree as Any,
            ],
            displayStyle: .struct
        )
    }
}

extension _AnyErrorCode: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "stableIdentifier": stableIdentifier,
                "identity": identity as Any,
                "domain": domain,
                "base": base,
            ],
            displayStyle: .struct
        )
    }
}

extension _AnyErrorCodeCatalog: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "descriptor": descriptor,
                "allErrorCodes": allErrorCodes,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorCodeCatalogDescriptor: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "catalogIdentifier": catalogIdentifier,
                "entries": entries,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorCodeCatalogEntry: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "stableIdentifier": stableIdentifier,
                "integerCode": integerCode,
                "identity": identity as Any,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorIdentity: CustomReflectable {
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

extension _ErrorContextBinding: CustomReflectable {
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

extension _ErrorTraits: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "elements": elements,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorChain: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "elements": elements,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorFailureTree: CustomReflectable {
    public var customMirror: Mirror {
        switch self {
            case .error(let error):
                return Mirror(
                    self,
                    children: [
                        "error": error,
                    ],
                    displayStyle: .enum
                )
            case .relation(let relation):
                return Mirror(
                    self,
                    children: [
                        "relation": relation,
                    ],
                    displayStyle: .enum
                )
        }
    }
}

extension _ErrorFailureRelation: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "role": role,
                "children": children,
                "context": context,
            ],
            displayStyle: .struct
        )
    }
}

extension _AnyErrorReportScenario: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "typeIdentifier": typeIdentifier,
                "stableIdentifier": stableIdentifier,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorReport.IdentityOccurrence: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "chainIndex": chainIndex,
                "error": error,
                "identity": identity,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorReport.FailureIdentityOccurrence: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "path": path,
                "relationRoles": relationRoles,
                "error": error,
                "identity": identity,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorReport.FailureContextOccurrence: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "path": path,
                "relationRoles": relationRoles,
                "context": context,
            ],
            displayStyle: .struct
        )
    }
}

extension _ErrorReport: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "root": root,
                "chain": chain,
                "failureTree": failureTree,
                "scenario": scenario as Any,
                "identity": identity as Any,
                "headlineIdentity": headlineIdentity as Any,
                "allIdentities": allIdentities,
                "identityOccurrences": identityOccurrences,
                "failureIdentityOccurrences": failureIdentityOccurrences,
                "failureContextOccurrences": failureContextOccurrences,
                "traits": traits,
                "presentation": presentation as Any,
                "recoverySuggestions": recoverySuggestions,
                "context": context,
                "observation": observation,
            ],
            displayStyle: .struct
        )
    }
}
