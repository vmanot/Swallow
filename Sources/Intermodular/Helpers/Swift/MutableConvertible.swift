//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _MutableConvertible {
    associatedtype ImmutableRepresentation = Self
    associatedtype MutableRepresentation
    
    var immutableRepresentation: ImmutableRepresentation { get }
    var mutableRepresentation: MutableRepresentation { get }
}

public protocol MutableConvertible: _MutableConvertible where ImmutableRepresentation: _MutableConvertible, MutableRepresentation: _MutableConvertible {
    var immutableRepresentation: ImmutableRepresentation { get }
    var mutableRepresentation: MutableRepresentation { get }
}

// MARK: - Implementation -

extension MutableConvertible where ImmutableRepresentation == Self {
    public var immutableRepresentation: ImmutableRepresentation {
        return self
    }
}

extension MutableConvertible where MutableRepresentation == Self {
    public var mutableRepresentation: MutableRepresentation {
        get {
            return self
        } set {
            self = newValue
        }
    }
}
