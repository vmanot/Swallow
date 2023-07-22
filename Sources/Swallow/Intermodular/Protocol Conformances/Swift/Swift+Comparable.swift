//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyComparable {
    public let base: any Comparable
    
    private let isGreaterThanImpl: ((Any, Any) -> Bool)
    private let isLessThanImpl: ((Any, Any) -> Bool)

    public init<T: Comparable>(erasing base: T) {
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
        
        self.base = base
        self.isGreaterThanImpl = isGreaterThan
        self.isLessThanImpl = isLessThan
    }
}

// MARK: - Conformances

extension AnyComparable: Equatable {
    public static func == (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        AnyEquatable.equate(lhs.base, rhs.base)
    }
}

extension AnyComparable: Comparable {
    public static func < (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        lhs.isLessThanImpl(lhs.base, rhs.base)
    }
    
    public static func > (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        lhs.isGreaterThanImpl(lhs.base, rhs.base)
    }
}

// MARK: - Extensions

extension AnyComparable {
    /// Whether this value is comparable with another value.
    public func isComparable(with other: AnyComparable) -> Bool {
        func _isComparableWithOther<T: Comparable>(_ base: T) -> Bool {
            other._isComparable(with: base)
        }
        
        return _openExistential(self.base, do: _isComparableWithOther)
    }
    
    private func _isComparable<T: Comparable>(with other: T) -> Bool {
        return base is T
    }
}

// MARK: - Supplementary

extension Comparable {
    public var erasedAsAnyComparable: AnyComparable {
        .init(erasing: self)
    }
}
