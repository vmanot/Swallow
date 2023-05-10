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
        name
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
        _getTypeName(from: _unwrapBase())
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
private func _getTypeName(
    from type: Any.Type,
    qualified: Bool = true,
    genericsAbbreviated: Bool = false  // NB: This defaults to `true` in Custom Dump
) -> String {
    var name = _typeName(type, qualified: qualified)
        .replacingOccurrences(
            of: #"\(unknown context at \$[[:xdigit:]]+\)\."#,
            with: "",
            options: .regularExpression
        )
    for _ in 1...10 {  // NB: Only handle so much nesting
        let abbreviated =
        name
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
        if abbreviated == name { break }
        name = abbreviated
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
