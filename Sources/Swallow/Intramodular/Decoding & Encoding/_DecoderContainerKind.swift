//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// The kind of container vended by a `Decoder`.
@frozen
public enum _DecodingContainerKind: CaseIterable, Hashable {
    public static var allCases: [_DecodingContainerKind] {
        [.keyed(by: AnyCodingKey.self), .unkeyed, .singleValue]
    }
    
    /// A single value decoding container.
    case singleValue
    
    /// An unkeyed decoding container.
    case unkeyed
    
    /// A keyed decoding container.
    case keyed(by: Metatype<any CodingKey.Type>)
    
    public static func keyed(by type: any CodingKey.Type) -> Self {
        self.keyed(by: Metatype(type))
    }
}

extension _DecodingContainerKind {
    public enum _ComparisonType {
        case singleValue
        case unkeyed
        case keyed
    }
    
    public static func == (lhs: Self, rhs: _ComparisonType) -> Bool {
        switch (lhs, rhs) {
            case (.singleValue, .singleValue):
                return true
            case (.unkeyed, .unkeyed):
                return true
            case (.keyed, .keyed):
                return true
            default:
                return false
        }
    }
}
 
extension Decoder {
    public func _container(
        ofKind kind: _DecodingContainerKind
    ) throws -> Any {
        switch kind {
            case .singleValue:
                return try singleValueContainer()
            case .unkeyed:
                return try unkeyedContainer()
            case .keyed(let keyType):
                return try keyType.value._getContainer(from: self)
        }
    }
}

fileprivate extension CodingKey {
    static func _getContainer(
        from decoder: Decoder
    ) throws -> any KeyedDecodingContainerProtocol {
        try decoder.container(keyedBy: self)
    }
}
