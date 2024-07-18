//
// Copyright (c) Vatsal Manot
//

import Foundation

public protocol PredicateExpressionPrimitiveConvertible {
    func toPredicateExpressionPrimitive() -> PredicateExpressionPrimitive
}

public protocol PredicateExpressionPrimitive {
    static var predicatePrimitiveType: PredicateExpressionPrimitiveType { get }
}

public indirect enum PredicateExpressionPrimitiveType: Equatable {
    case bool
    case int
    case int8
    case int16
    case int32
    case int64
    case uint
    case uint8
    case uint16
    case uint32
    case uint64
    case double
    case float
    case string
    case date
    case url
    case uuid
    case data
    case object
    case wrapped(PredicateExpressionPrimitiveType)
    case array(PredicateExpressionPrimitiveType)
    case `nil`
}

extension Bool: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .bool
}

extension Int: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .int
}

extension Int8: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .int8
}

extension Int16: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .int16
}

extension Int32: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .int32
}

extension Int64: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .int64
}

extension UInt: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .uint
}

extension UInt8: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .uint8
}

extension UInt16: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .uint16
}

extension UInt32: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .uint32
}

extension UInt64: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .uint64
}

extension Double: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .double
}

extension Float: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .float
}

extension String: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .string
}

extension Data: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .data
}

extension Date: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .date
}

extension PredicateExpressionPrimitive where Self: RawRepresentable, RawValue: PredicateExpressionPrimitive {
    public static var predicatePrimitiveType: PredicateExpressionPrimitiveType { RawValue.predicatePrimitiveType
    }
}

extension Array: PredicateExpressionPrimitive where Element: PredicateExpressionPrimitive {
    public static var predicatePrimitiveType: PredicateExpressionPrimitiveType {
        .array(Element.predicatePrimitiveType)
    }
}

extension URL: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .url
}

extension UUID: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .uuid
}

extension NSObject: PredicateExpressionPrimitive {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .object
}

extension Optional: PredicateExpressionPrimitive where Wrapped: PredicateExpressionPrimitive {
    public static var predicatePrimitiveType: PredicateExpressionPrimitiveType { Wrapped.predicatePrimitiveType
    }
}

public struct NilPredicateExpressionValue: PredicateExpressionPrimitive, ExpressibleByNilLiteral {
    public static let predicatePrimitiveType: PredicateExpressionPrimitiveType = .nil
    
    public init(nilLiteral: ()) {
        
    }
}
