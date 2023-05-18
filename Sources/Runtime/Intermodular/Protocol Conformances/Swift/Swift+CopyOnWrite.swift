//
// Copyright (c) Vatsal Manot
//

import Swallow

extension Array: CopyOnWrite {
    public var isUniquelyReferenced: Bool {
        mutating get {
            isKnownUniquelyReferenced(&UnsafeMutablePointer.to(&self).assumingMemoryBound(to: AnyObject.self).pointee)
        }
    }

    public mutating func makeUniquelyReferenced() {
        self = Array(self)
    }
}

extension ContiguousArray: CopyOnWrite {
    public var isUniquelyReferenced: Bool {
        mutating get {
            isKnownUniquelyReferenced(&UnsafeMutablePointer.to(&self).assumingMemoryBound(to: AnyObject.self).pointee)
        }
    }

    public mutating func makeUniquelyReferenced() {
        self = ContiguousArray(self)
    }
}

extension Dictionary: CopyOnWrite {
    public var isUniquelyReferenced: Bool {
        mutating get {
            isKnownUniquelyReferenced(&UnsafeMutablePointer.to(&self).assumingMemoryBound(to: AnyObject.self).pointee)
        }
    }

    public mutating func makeUniquelyReferenced() {
        self = Dictionary(self)
    }
}

extension Set: CopyOnWrite {
    public var isUniquelyReferenced: Bool {
        mutating get {
            isKnownUniquelyReferenced(&UnsafeMutablePointer.to(&self).assumingMemoryBound(to: AnyObject.self).pointee)
        }
    }

    public mutating func makeUniquelyReferenced() {
        self = Set(self)
    }
}
