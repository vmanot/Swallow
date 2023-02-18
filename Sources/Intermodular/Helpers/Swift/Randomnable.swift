//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type capable of generating random instances of itself.
public protocol Randomnable {
    static func random() -> Self
}

/// A bounded type capable of generating random instances of itself.
public protocol BoundedRandomnable: Bounded, Randomnable {
    static func random(minimum: Self, maximum: Self) -> Self
    static func random(minimum: Self) -> Self
    static func random(maximum: Self) -> Self
}

// MARK: - Implementation

extension BoundedRandomnable {
    public static func random() -> Self {
        return random(minimum: minimum, maximum: maximum)
    }
    
    public static func random(minimum: Self) -> Self {
        return random(minimum: minimum, maximum: maximum)
    }
    
    public static func random(maximum: Self) -> Self {
        return random(minimum: minimum, maximum: maximum)
    }
}

// MARK: - Implementation

extension Randomnable where Self: RawRepresentable, RawValue: Randomnable {
    public static func random() -> Self {
        self.init(rawValue: RawValue.random())!
    }
}

// MARK: - Extensions

extension BoundedRandomnable where Self: Strideable {
    public static func random(
        minimum: Self = .minimum,
        maximum: Self = .maximum,
        excluding range: Range<Self>
    ) -> Self {
        var result: Self
        
        repeat {
            result = random(minimum: minimum, maximum: maximum)
        }
        
        while range.contains(result)
                
                return result
    }
    
    public static func random(
        minimum: Self = .minimum,
        maximum: Self = .maximum,
        excluding element: Self
    ) -> Self {
        return random(minimum: minimum, maximum: maximum, excluding: Range(element))
    }
}
