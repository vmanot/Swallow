//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct AnyStructure: FailableWrapper {
    public typealias Value = Any
    
    public let value: Value
    
    public init(uncheckedValue value: Value) {
        self.value = value
    }
    
    public init?(_ value: Value) {
        guard let _ = TypeMetadata.Structure(type(of: value)) else {
            return nil
        }
        
        self.init(uncheckedValue: value)
    }
}
