//
// Copyright (c) Vatsal Manot
//

import Swift

/// A strongly typed mirror over a subject of a nominal type.
public struct NominalMirror<Subject>: MirrorType {
    public var subject: Subject
    public let typeMetadata: TypeMetadata.NominalOrTuple
    
    public var supertypeMirror: NominalMirror<Any>? {
        AnyNominalOrTupleMirror(self).supertypeMirror.flatMap(NominalMirror<Any>.init)
    }
    
    public var children: AnyNominalOrTupleMirror.Children {
        AnyNominalOrTupleMirror(self).children
    }
    
    public var allChildren: AnyNominalOrTupleMirror.AllChildren {
        AnyNominalOrTupleMirror(self).allChildren
    }
    
    private init(subject: Subject, typeMetadata: TypeMetadata.NominalOrTuple) {
        self.subject = subject
        self.typeMetadata = typeMetadata
    }
}

// MARK: - API

extension NominalMirror {
    public init(reflecting subject: Subject) {
        self.init(subject: subject, typeMetadata: .of(subject))
    }

    public subscript<T>(keyPath keyPath: KeyPath<Subject, T>) -> T{
        subject[keyPath: keyPath]
    }
    
    public subscript<T>(keyPath keyPath: WritableKeyPath<Subject, T>) -> T {
        get {
            subject[keyPath: keyPath]
        } set {
            subject[keyPath: keyPath] = newValue
        }
    }
}

// MARK: - Auxiliary

extension NominalMirror {
    public init?(_ value: AnyNominalOrTupleMirror) {
        guard let subject = value.value as? Subject else {
            return nil
        }
        
        self.init(subject: subject, typeMetadata: value.typeMetadata)
    }
}

extension AnyNominalOrTupleMirror {
    public init<T>(_ mirror: NominalMirror<T>) {
        self.init(unchecked: mirror.subject, typeMetadata: mirror.typeMetadata)
    }
}
