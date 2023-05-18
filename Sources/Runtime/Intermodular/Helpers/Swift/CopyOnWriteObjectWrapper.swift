//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct CopyOnWriteObjectWrapper<T: AnyObject> {
    private var object: ReferenceBox<T>
    private var duplicator: ((inout T) -> T)
    
    public init(_ object: T, duplicator: (@escaping (inout T) -> T)) {
        self.object = .init(object)
        self.duplicator = duplicator
    }
}

// MARK: - Conformances

extension CopyOnWriteObjectWrapper: CopyOnWrite {
    public var isUniquelyReferenced: Bool {
        mutating get {
            return isKnownUniquelyReferenced(&object)
        }
    }
    
    public mutating func makeUniquelyReferenced() {
        object = .init(duplicator(&object.value))
    }
}

extension CopyOnWriteObjectWrapper: MutableValueConvertible {
    public typealias Value = T
    
    public var value: T {
        get {
            return object.value
        } set {
            ensureIsUniquelyReferenced()
            
            object.value = newValue
        }
    }
}
