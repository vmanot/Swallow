//
// Copyright (c) Vatsal Manot
//

import Swift

extension Bool {
    public struct True {
        
    }
    
    public struct False {
        
    }
}

prefix operator &&

public prefix func && <T>(rhs: (@escaping (T) -> Bool)) -> ((Bool, T) -> Bool) {
    return { $0 && rhs($1) }
}
