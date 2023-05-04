//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _MutableRepresentationConvertible {
    associatedtype ImmutableRepresentation = Self
    associatedtype MutableRepresentation
    
    var immutableRepresentation: ImmutableRepresentation { get }
    var mutableRepresentation: MutableRepresentation { get }
}

public protocol MutableRepresentationConvertible: _MutableRepresentationConvertible where ImmutableRepresentation: _MutableRepresentationConvertible, MutableRepresentation: _MutableRepresentationConvertible {
    var immutableRepresentation: ImmutableRepresentation { get }
    var mutableRepresentation: MutableRepresentation { get }
}

// MARK: - Implementation

extension MutableRepresentationConvertible where ImmutableRepresentation == Self {
    public var immutableRepresentation: ImmutableRepresentation {
        return self
    }
}

extension MutableRepresentationConvertible where MutableRepresentation == Self {
    public var mutableRepresentation: MutableRepresentation {
        get {
            return self
        } set {
            self = newValue
        }
    }
}
