//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_Optional: AnyProtocol {
    static var opaque_Optional_Wrapped: Any.Type { get }

    var isNil: Bool { get }

    var opaque_Optional_wrapped: Any? { get }

    init(none: Void)

    mutating func opaque_Optional_set(wrapped: Any?) -> Void?
}

extension opaque_Optional where Self: OptionalProtocol {
    public static var opaque_Optional_Wrapped: Any.Type {
        return RightValue.self
    }

    public var isNil: Bool {
        return isRight
    }

    public var opaque_Optional_wrapped: Any? {
        return leftValue.flatMap(Optional<Any>.some)
    }

    public mutating func opaque_Optional_set(wrapped: Any?) -> Void? {
        guard let wrapped: LeftValue = -?>wrapped else {
            return nil
        }

        self = .init(leftValue: wrapped)
        return ()
    }
}
// MARK: - Extensions -

extension opaque_Optional {
    public var isNotNil: Bool {
        return !isNil
    }

    public func opaque_Optional_flattening() -> Any? {
        var result = opaque_Optional_wrapped

        if let value = result, let _value = (value as? opaque_Optional) {
            result = _value.opaque_Optional_flattening()
        }

        return result
    }

    public func opaque_Optional_valueOrNil() -> Any {
        let flattened = opaque_Optional_flattening()

        return (flattened != nil) ? flattened! : (flattened as Any)
    }
}

// MARK: - Helpers -

extension Sequence {
    @inlinable
    public func nilIfEmpty() -> Self? {
        return first(where: { _ in true }).map({ _ in self })
    }
}

public func lowerFromOptionalIfPossible(_ value: Any) -> Any {
    return (value as Any?).opaque_Optional_valueOrNil()
}
