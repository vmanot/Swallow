//
// Copyright (c) Vatsal Manot
//

import Foundation
import ObjectiveC
import Swift

public protocol HasDelegate: NSObjectProtocol {
    associatedtype Delegate: AnyObject
    
    var delegate: Delegate? { get set }
    var delegateType: Delegate.Type { get }
    var delegateProtocol: Protocol { get }
    
    func _setDelegate(_ delegate: Delegate?)
}

public protocol HasWeakDelegate: HasDelegate {
    var delegate: Delegate? { get set }
}

// MARK: - Implementation
extension HasDelegate {
    public var delegateType: Delegate.Type {
        return Delegate.self
    }
    
    public func _setDelegate(_ delegate: Delegate?) {
        self.delegate = delegate
    }
}
