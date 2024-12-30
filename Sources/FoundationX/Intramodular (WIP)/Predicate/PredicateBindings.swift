//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct PredicateBindings {
    private var storage: [(id: PredicateExpressionsX.VariableID, value: Any)]
    
    public init<T>(_ variable: (PredicateExpressionsX.Variable<T>, T)) {
        self.storage = [(variable.0.key, variable.1)]
    }
    
    public subscript<T>(_ variable: PredicateExpressionsX.Variable<T>) -> T? {
        get {
            storage.first {
                $0.id == variable.key
            }?.value as? T
        }
        set {
            let found = storage.firstIndex {
                $0.id == variable.key
            }
            
            guard let newValue else {
                if let found {
                    storage.remove(at: found)
                }
                
                return
            }
            
            if let found {
                storage[found].value = newValue
            } else {
                storage.append((variable.key, newValue))
            }
        }
    }
    
    public func binding<T>(_ variable: PredicateExpressionsX.Variable<T>, to value: T) -> Self {
        var mutable = self
        
        mutable[variable] = value
        
        return mutable
    }
}
