//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ImplementationForwarder: AnyProtocol {
    associatedtype ImplementationProvider
    
    var implementationProvider: ImplementationProvider { get }
    
    init(implementationProvider: ImplementationProvider)
}

public protocol MutableImplementationForwarder: ImplementationForwarder {
    var implementationProvider: ImplementationProvider { get set }
}

public protocol ImplementationForwardingRawRepresentable: ImplementationForwarder, RawRepresentable where ImplementationProvider == RawValue {
    init(rawValue: RawValue)
}

public protocol ImplementationForwardingMutableRawRepresentable: ImplementationForwardingRawRepresentable, MutableImplementationForwarder, MutableRawRepresentable {

}

public protocol ImplementationForwardingStore: ImplementationForwarder, Store where ImplementationProvider == Storage {

}

public protocol ImplementationForwardingMutableStore: ImplementationForwardingStore, MutableImplementationForwarder, MutableStore {

}

public protocol ImplementationForwardingWrapper: ImplementationForwarder, Wrapper where ImplementationProvider == Value {

}

public protocol ImplementationForwardingMutableWrapper: ImplementationForwardingWrapper, MutableImplementationForwarder, MutableWrapper {

}

// MARK: - Extensions -

extension ImplementationForwarder {
    public init?(implementationProvider: ImplementationProvider?) {
        guard let implementationProvider = implementationProvider else {
            return nil
        }
        
        self.init(implementationProvider: implementationProvider)
    }
}

// MARK: - Implementation -

extension ImplementationForwardingRawRepresentable {
    public var implementationProvider: RawValue {
        return rawValue
    }
    
    public init(implementationProvider: RawValue) {
        self.init(rawValue: implementationProvider)
    }
}

extension ImplementationForwardingMutableRawRepresentable {
    public var implementationProvider: RawValue {
        get {
            return rawValue
        } set {
            rawValue = newValue
        }
    }
}

extension ImplementationForwardingStore {
    public var implementationProvider: Storage {
        return storage
    }
    
    public init(implementationProvider: Storage) {
        self.init(storage: implementationProvider)
    }
}

extension ImplementationForwardingMutableStore {
    public var implementationProvider: Storage {
        get {
            return storage
        } set {
            storage = newValue
        }
    }
}

extension ImplementationForwardingWrapper {
    public var implementationProvider: Value {
        return value
    }
    
    public init(implementationProvider: Value) {
        self.init(implementationProvider)
    }
}

extension ImplementationForwardingMutableWrapper {
    public var implementationProvider: Value {
        get {
            return value
        } set {
            value = newValue
        }
    }
}
