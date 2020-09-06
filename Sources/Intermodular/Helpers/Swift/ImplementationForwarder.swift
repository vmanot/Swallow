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
