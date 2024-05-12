//
// Copyright (c) Vatsal Manot
//

import Swift

/// A `Hashable` representation of a metatype.
///
/// More useful than `ObjectIdentifier` as it exposes access to the underlying value.
@propertyWrapper
public struct Metatype<T>: @unchecked Sendable {
    public let value: T
        
    public var wrappedValue: T{
        value
    }
    
    public init(_ value: T) {
        #if DEBUG
        guard let _ = value as? Any.Type else {
            self.value = value
            
            assertionFailure()
            
            return
        }
        #endif

        self.value = value
    }
    
    public init(wrappedValue: T) {
        self.init(wrappedValue)
    }
}

extension Metatype {
    public func _isAnyOrNever(unwrapIfNeeded: Bool = false) -> Bool {
        let type = _unwrapBase()
        
        switch type {
            case Any.self:
                return true
            case AnyObject.self:
                return true
            case Never.self:
                return true
            default:
                break
        }
        
        guard unwrapIfNeeded else {
            return false
        }
        
        switch type {
            case Optional<Any>.self:
                return true
            case Optional<AnyObject>.self:
                return true
            case Optional<Never>.self:
                assertionFailure()
                
                return true
            default:
                break
        }
        
        return false
    }
}

// MARK: - Conformances

extension Metatype: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        String(describing: value)
    }

    public var description: String {
        name
    }
}

extension Metatype: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(_unwrapBase()))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._unwrapBase() == rhs._unwrapBase()
    }
}

extension Metatype: Named {
    public var name: String {
        _getSanitizedTypeName(from: _unwrapBase())
    }
}

// MARK: - Auxiliary

public protocol _SwallowMetatypeType {
    func _unwrapBase() -> Any.Type
}

extension Metatype: _UnwrappableTypeEraser {
    public init(_erasing base: Any.Type) {
        assertionFailure()
        
        self.init(base as! T)
    }
    
    public func _unwrapBase() -> Any.Type {
        value as! Any.Type
    }
}

/// From pointfreeco.
public func _getSanitizedTypeName(
    from type: Any.Type,
    qualified: Bool = true,
    genericsAbbreviated: Bool = false
) -> String {
    var name = _typeName(type, qualified: qualified)
        .replacingOccurrences(
            of: #"\(unknown context at \$[[:xdigit:]]+\)\."#,
            with: "",
            options: .regularExpression
        )
    for _ in 1...10 {
        let abbreviatedName = name
            .replacingOccurrences(
                of: #"\bSwift.Optional<([^><]+)>"#,
                with: "$1?",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: #"\bSwift.Array<([^><]+)>"#,
                with: "[$1]",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: #"\bSwift.Dictionary<([^,<]+), ([^><]+)>"#,
                with: "[$1: $2]",
                options: .regularExpression
            )
        
        if abbreviatedName == name {
            break
        }
        
        name = abbreviatedName
    }
    
    name = name.replacingOccurrences(
        of: #"\w+\.([\w.]+)"#,
        with: "$1",
        options: .regularExpression
    )
    
    if genericsAbbreviated {
        name = name.replacingOccurrences(
            of: #"<.+>"#,
            with: "",
            options: .regularExpression
        )
    }
    
    return name
}
