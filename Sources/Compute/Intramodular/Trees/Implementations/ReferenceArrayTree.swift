//
// Copyright (c) Vatsal Manot
//

import Foundation
import Combine
import Swallow

public final class ReferenceArrayTree<Value>: ConstructibleTree, Identifiable, MutableRecursiveTree, ObservableObject, HomogenousTree {
    public weak private(set) var parent: ReferenceArrayTree?
    
    public var value: Value {
        willSet {
            _triggerObjectWillChangeEvent()
        } didSet {
            if let oldValue = oldValue as? (any ReferenceArrayTreeValueObject) {
                oldValue._opaque_parent = nil
            }
            
            _updateValueLink()
        }
    }
    
    public var children: [ReferenceArrayTree] {
        willSet {
            _triggerObjectWillChangeEvent()
        } didSet {
            oldValue.forEach {
                $0.parent = nil
            }
            
            _updateChildrenLinks()
        }
    }
    
    public init(value: Value, children: [ReferenceArrayTree]) {
        self.value = value
        self.children = children
            
        (value as? (any ReferenceArrayTreeValueObject))?._opaque_unsafelyAccessedParent = self
        
        _updateChildrenLinks()
    }
        
    private func _updateValueLink() {
        if let value = value as? (any ReferenceArrayTreeValueObject) {
            value._opaque_parent = self
        }
    }
    
    private func _updateChildrenLinks() {
        children.forEach {
            $0.parent = self
        }
    }
    
    private func _triggerObjectWillChangeEvent() {
        objectWillChange.send()
        
        if self !== root {
            root._triggerObjectWillChangeEvent()
        }
    }
}

extension ReferenceArrayTree {
    public var root: ReferenceArrayTree {
        parent?.root ?? self
    }
}

public protocol ReferenceArrayTreeValueObject: AnyObject {
    var _unsafelyAccessedParent: ReferenceArrayTree<Self>? { get set }
    var parent: ReferenceArrayTree<Self>? { get set }
}

extension ReferenceArrayTreeValueObject {
    var _opaque_parent: AnyObject? {
        get {
            parent
        } set {
            parent = newValue.map({ $0 as! ReferenceArrayTree })
        }
    }
    
    var _opaque_unsafelyAccessedParent: AnyObject? {
        get {
            _unsafelyAccessedParent
        } set {
            _unsafelyAccessedParent = newValue.map({ $0 as! ReferenceArrayTree })
        }
    }
}

extension ReferenceArrayTreeValueObject {
    public var isRoot: Bool {
        parent?.parent == nil
    }
}
