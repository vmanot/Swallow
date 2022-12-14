//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyComparable: Comparable {
    private var isEqualToImpl: ((Any, Any) -> Bool)
    private var isGreaterThanImpl: ((Any, Any) -> Bool)
    private var isLessThanImpl: ((Any, Any) -> Bool)
    
    public let base: Any
    
    public init<T: Comparable>(_ base: T) {
        func equate(_ x: Any, _ y: Any) -> Bool {
            guard let x = x as? T, let y = y as? T else {
                return false
            }
            
            return x == y
        }
        
        func isGreaterThan(_ x: Any, _ y: Any) -> Bool {
            guard let x = x as? T, let y = y as? T else {
                return false
            }
            
            return x > y
        }
        
        func isLessThan(_ x: Any, _ y: Any) -> Bool {
            guard let x = x as? T, let y = y as? T else {
                return false
            }
            
            return x < y
        }
        
        self.isEqualToImpl = equate
        self.isGreaterThanImpl = isGreaterThan
        self.isLessThanImpl = isLessThan
        self.base = base
    }
    
    public static func == (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        return lhs.isEqualToImpl(lhs.base, rhs.base)
    }
    
    public static func < (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        return lhs.isLessThanImpl(lhs.base, rhs.base)
    }
    
    public static func > (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        return lhs.isGreaterThanImpl(lhs.base, rhs.base)
    }
}
