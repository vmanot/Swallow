//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// Portable structured context attached to a diagnostic event.
///
/// The value model is deliberately the common, lossless subset supported by
/// PassthroughLogger and swift-log. OSLog preserves its richer message
/// interpolation and privacy model, but has no equivalent arbitrary metadata
/// channel.
public typealias DiagnosticLogMetadata = [String: DiagnosticLogMetadataValue]

/// A value that can preserve its semantics when attached to a portable
/// diagnostic event.
public protocol DiagnosticLogMetadataValueConvertible: Sendable {
    var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { get }
}

public enum DiagnosticLogMetadataValue: Codable, Hashable, Sendable,
    DiagnosticLogMetadataValueConvertible
{
    case string(String)
    indirect case array([Self])
    indirect case dictionary(DiagnosticLogMetadata)

    public init<Value: DiagnosticLogMetadataValueConvertible>(
        _ value: Value
    ) {
        self = value.diagnosticLogMetadataValue
    }

    public var diagnosticLogMetadataValue: Self {
        self
    }

    /// A deliberately lossy bridge for the pre-Sendable `[String: Any]` API.
    public init(describingLegacyValue value: Any) {
        if let value = value as? any DiagnosticLogMetadataValueConvertible {
            self = value.diagnosticLogMetadataValue
            return
        }

        switch value {
        case let value as [String: Any]:
            self = .dictionary(value.mapValues(Self.init(describingLegacyValue:)))
        case let value as [Any]:
            self = .array(value.map(Self.init(describingLegacyValue:)))
        default:
            self = .string(String(describing: value))
        }
    }
}

extension DiagnosticLogMetadataValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let value):
            value
        case .array(let values):
            "[" + values.map(\.description).joined(separator: ", ") + "]"
        case .dictionary(let values):
            "["
                + values.sorted(by: { $0.key < $1.key }).map {
                    "\($0.key): \($0.value.description)"
                }.joined(separator: ", ") + "]"
        }
    }
}

extension DiagnosticLogMetadataValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension DiagnosticLogMetadataValue: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self = .string(String(stringInterpolation: stringInterpolation))
    }
}

extension DiagnosticLogMetadataValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Self...) {
        self = .array(elements)
    }
}

extension DiagnosticLogMetadataValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Self)...) {
        self = .dictionary(Dictionary(elements, uniquingKeysWith: { _, latest in latest }))
    }
}

extension DiagnosticLogMetadataValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .string(value.description)
    }
}

extension DiagnosticLogMetadataValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .string(value.description)
    }
}

extension DiagnosticLogMetadataValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .string(value.description)
    }
}

extension Dictionary where Key == String, Value == DiagnosticLogMetadataValue {
    public init<SourceValue: DiagnosticLogMetadataValueConvertible>(
        converting metadata: [String: SourceValue]
    ) {
        self = metadata.mapValues(\.diagnosticLogMetadataValue)
    }

    public init(describingLegacyMetadata metadata: [String: Any]) {
        self = metadata.mapValues(DiagnosticLogMetadataValue.init(describingLegacyValue:))
    }
}

// MARK: - Standard Value Conformances

extension String: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue {
        .string(self)
    }
}

extension Substring: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue {
        .string(String(self))
    }
}

extension Bool: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue {
        .string(description)
    }
}

extension Int: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension Int8: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension Int16: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension Int32: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension Int64: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension UInt: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension UInt8: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension UInt16: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension UInt32: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension UInt64: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension Float: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension Double: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue { .string(description) }
}

extension URL: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue {
        .string(isFileURL ? path : absoluteString)
    }
}

extension Array: DiagnosticLogMetadataValueConvertible
where Element: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue {
        .array(map(\.diagnosticLogMetadataValue))
    }
}

extension Dictionary: DiagnosticLogMetadataValueConvertible
where Key == String, Value: DiagnosticLogMetadataValueConvertible {
    public var diagnosticLogMetadataValue: DiagnosticLogMetadataValue {
        .dictionary(mapValues(\.diagnosticLogMetadataValue))
    }
}
