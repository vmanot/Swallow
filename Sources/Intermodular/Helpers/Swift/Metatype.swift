//
// Copyright (c) Vatsal Manot
//

import Swift

/// A `Hashable` representation of a metatype.
///
/// More useful than `ObjectIdentifier` as it exposes access to the underlying value.
public struct Metatype<T>: CustomStringConvertible, Hashable, @unchecked Sendable {
    public let value: T
    
    public var description: String {
        String(describing: value)
    }
    
    public var debugDescription: String {
        String(describing: value)
    }
    
    public init(_ value: T) {
        guard let _ = value as? Any.Type else {
            self.value = value
            
            assertionFailure()
            
            return
        }
        
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(value as! Any.Type))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.value as! Any.Type) == (rhs.value as! Any.Type)
    }
}

// MARK: - Extensions

extension Metatype {
    public var name: String {
        var name = _typeName(_unwrapBase(), qualified: true)
        
        if let index = name.firstIndex(of: ".") {
            name.removeSubrange(...index)
        }

        return name.replacingOccurrences(
            of: #"\(unknown context at \$[[:xdigit:]]+\)\."#,
            with: "",
            options: .regularExpression
        )
    }
}

// MARK: - Auxiliary

public protocol _SwallowMetatypeType {
    func _unwrapBase() -> Any.Type
}

extension Metatype: _UnwrappableTypeEraser {
    public func _unwrapBase() -> Any.Type {
        value as! Any.Type
    }
}
