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
