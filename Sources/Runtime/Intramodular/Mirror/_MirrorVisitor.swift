//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A mirror that supports visitor-traversal.
public protocol _MirrorVisitor {
    func shouldVisitChildren<T>(
        of subject: T,
        at path: [_AnyMirrorPathElement]
    ) -> Bool
    
    func visit<T>(
        _ mirror: InstanceMirror<T>,
        at path: [_AnyMirrorPathElement]
    ) throws
}

public protocol _VisitableMirror<Subject> {
    associatedtype Subject
    
    /// Walk a given visitor through the desired path.
    func walk(
        visitor: some _MirrorVisitor,
        at path: [_AnyMirrorPathElement]
    ) throws
}

// MARK: - Extensions

extension _MirrorVisitor {
    public func visit<T>(
        _ mirror: InstanceMirror<T>
    ) throws {
        try mirror.walk(visitor: self, at: [])
    }
}

extension InstanceMirror {
    public func walk(
        visitor: some _MirrorVisitor,
        at path: [_AnyMirrorPathElement]
    ) throws {
        guard visitor.shouldVisitChildren(of: subject, at: path) else {
            return
        }
        
        try visitor.visit(self, at: path)
        
        for (field, childValue) in self {
            let fieldPath = path.appending(.field(field))
            
            guard visitor.shouldVisitChildren(of: childValue, at: fieldPath) else {
                continue
            }
            
            if let childMirror = _InstanceMirror_init(childValue) {
                try childMirror.walk(visitor: visitor, at: fieldPath)
            }
        }
    }
}

// MARK: - Auxiliary

public enum _AnyMirrorPathElement: Hashable, Sendable {
    case field(AnyCodingKey)
}

// MARK: - Internal

private func _InstanceMirror_init(_ x: Any) -> (any _VisitableMirror)? {
    func makeMirror<T>(_ subject: T) -> (any _VisitableMirror)? {
        InstanceMirror(subject)
    }
    
    return _openExistential(x, do: makeMirror)
}
