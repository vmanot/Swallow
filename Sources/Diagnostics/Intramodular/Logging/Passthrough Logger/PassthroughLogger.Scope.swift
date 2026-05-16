//
// Copyright (c) Vatsal Manot
//

import Swift

extension PassthroughLogger {
    public enum Scope: LogScope, Hashable {
        case root
        
        indirect case child(parent: Self, scope: AnyLogScope)
    }
}

extension PassthroughLogger.Scope {
    public var path: [AnyLogScope] {
        switch self {
            case .root:
                return []
            case .child(let parent, let scope):
                return parent.path + [scope]
        }
    }
    
    public var textRepresentations: [LogScopeTextRepresentation] {
        path.map(\.textRepresentation)
    }
}

extension PassthroughLogger.Scope: CustomStringConvertible {
    public var description: String {
        switch self {
            case .root:
                return "root"
            case .child(let parent, let scope):
                return "\(parent) -> \(scope)"
        }
    }
}
