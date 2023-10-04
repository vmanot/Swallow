//
// Copyright (c) Vatsal Manot
//

import Swift

extension Mirror {
    /// The `children` of this `Mirror` enumerated as a dictionary.
    public var dictionaryRepresentation: [String: Any] {
        children
            .enumerated()
            ._map({ (key: $1.label ?? ".\(String(describing: $0))", value: $1.value) })
    }

    public func _reflectDescendant(at path: MirrorPath) -> Mirror? {
        guard let descendant = descendant(path) else {
            return nil
        }
        
        return Mirror(reflecting: descendant)
    }

    /// Flattens and destructures a tuple.
    public func _flattenAndDestructureTuple() throws -> [Any] {
        guard displayStyle == .tuple else {
            throw _TupleDestructuringError.notATuple(displayStyle)
        }
        
        return try children.map(\.value).flatMap { child -> [Any] in
            if Mirror(reflecting: child).displayStyle == .tuple {
                return try Mirror(reflecting: child)._flattenAndDestructureTuple()
            } else {
                return [child]
            }
        }
    }
    
    private enum _TupleDestructuringError: Error {
        case notATuple(Mirror.DisplayStyle?)
    }
}
