//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct ObjectEncoder: Initiable {
    public init() {
        
    }
    
    public func encode<T: Encodable>(
        _ value: T,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) throws -> NSCoding {
        do {
            let encoder = ObjectEncoder.Encoder(options, userInfo)
            var container = encoder.singleValueContainer()
            
            try container.encode(value)
            
            return try encoder.object.unwrap()
        } catch let error as EncodingError {
            throw error
        } catch {
            let description = "Unable to encode the given top-level value to Object."
            
            let context = EncodingError.Context(
                codingPath: [],
                debugDescription: description,
                underlyingError: error
            )
            
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    @_disfavoredOverload
    public func encode<T: Encodable, U>(
        _ value: T,
        as type: U.Type = U.self,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) throws -> U {
        let encoded = try self.encode(value, userInfo: userInfo)
        
        switch type {
            case Dictionary<AnyHashable, Any>.self: do {
                if let encoded = encoded as? [String: Any] {
                    return encoded.mapKeys({ AnyHashable($0) }) as! U
                }
            }
            default:
                break
        }
        
        return try cast(encoded)
    }
    
    public struct EncodingStrategy<T: Encodable> {
        public typealias Closure = (T, Encoder) throws -> Void
        
        public init(closure: @escaping Closure) {
            self.closure = closure
        }
        
        fileprivate let closure: Closure
    }
    
    public struct EncodingStrategies {
        var strategies = [ObjectIdentifier: Any]()
        
        public subscript<T>(type: T.Type) -> EncodingStrategy<T>? {
            get { return strategies[ObjectIdentifier(type)] as? EncodingStrategy<T> }
            set { strategies[ObjectIdentifier(type)] = newValue }
        }
        
        public init() {
            
        }
    }
    
    /// The strategies to use for encoding values.
    public var encodingStrategies: EncodingStrategies {
        get { return options.encodingStrategies }
        set { options.encodingStrategies = newValue }
    }
    
    fileprivate struct Options {
        fileprivate var encodingStrategies = EncodingStrategies()
    }
    
    fileprivate var options = Options()
}

extension ObjectEncoder {
    public class Encoder: Swift.Encoder {
        public final var object: NSCoding?
        
        fileprivate typealias Options = ObjectEncoder.Options
        
        fileprivate let options: Options
        
        fileprivate init(
            _ options: Options,
            _ userInfo: [CodingUserInfoKey: Any],
            _ codingPath: [CodingKey] = []
        ) {
            self.options = options
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
        
        public final let codingPath: [CodingKey]
        public final let userInfo: [CodingUserInfoKey: Any]
    }
}

extension ObjectEncoder.Encoder {
    public final func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        if canEncodeNewValue {
            object = [String: Any]() as NSCoding
        } else {
            precondition(
                object is [String: Any],
                "Attempt to push new keyed encoding container when already previously encoded at this path."
            )
        }
        return .init(ObjectEncoder._KeyedEncodingContainer<Key>(referencing: self))
    }
    
    public final func unkeyedContainer() -> UnkeyedEncodingContainer {
        if canEncodeNewValue {
            object = NSArray() as NSCoding
        } else {
            precondition(
                object is [Any],
                "Attempt to push new keyed encoding container when already previously encoded at this path."
            )
        }
        
        return ObjectEncoder._UnkeyedEncodingContainer(referencing: self)
    }
    
    public final func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
    
    fileprivate var dictionary: [String: Any] {
        get {
            return object as? [String: Any] ?? [:]
        } set {
            object = newValue as NSDictionary
        }
    }
    
    fileprivate var array: [Any] {
        get {
            return object as? [Any] ?? []
        }
        set {
            object = newValue as NSArray
        }
    }
    
    fileprivate func encoder(for key: CodingKey) -> ObjectEncoder._KeyReferencingEncoder {
        .init(referencing: self, key: key)
    }
    
    fileprivate func encoder(at index: Int) -> ObjectEncoder._IndexReferencingEncoder {
        .init(referencing: self, at: index)
    }
    
    private var canEncodeNewValue: Bool {
        guard let object = object else {
            return true
        }
        
        if let dictionary = object as? [String: Any], dictionary.isEmpty {
            return true
        }
        
        return false
    }
}

extension ObjectEncoder {
    fileprivate class _KeyReferencingEncoder: ObjectEncoder.Encoder {
        let encoder: ObjectEncoder.Encoder
        let key: String
        
        fileprivate init(referencing encoder: ObjectEncoder.Encoder, key: CodingKey) {
            self.encoder = encoder
            self.key = key.stringValue
            
            super.init(encoder.options, encoder.userInfo, encoder.codingPath + [key])
        }
        
        deinit {
            encoder.dictionary[key] = object
        }
    }
    
    fileprivate class _IndexReferencingEncoder: ObjectEncoder.Encoder {
        let encoder: ObjectEncoder.Encoder
        let index: Int
        
        fileprivate init(referencing encoder: ObjectEncoder.Encoder, at index: Int) {
            self.encoder = encoder
            self.index = index
            super.init(encoder.options, encoder.userInfo, encoder.codingPath + [_ObjectCodingKey(index: index)])
        }
        
        deinit {
            if let object = object {
                encoder.array[index] = object
            } else {
                assertionFailure()
            }
        }
    }
    
    fileprivate struct _KeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        private let encoder: ObjectEncoder.Encoder
        
        private func encoder(for key: CodingKey) -> _KeyReferencingEncoder {
            return encoder.encoder(for: key)
        }
        
        init(referencing encoder: ObjectEncoder.Encoder) {
            self.encoder = encoder
        }
        
        var codingPath: [CodingKey] {
            encoder.codingPath
        }
        
        func encodeNil(forKey key: Key) throws {
            try encoder(for: key).encodeNil()
        }
        
        func encode<T: CoderPrimitive>(_ value: T, forKey key: Key) throws {
            try encoder(for: key).encode(value)
        }
        
        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            try encoder(for: key).encode(value)
        }
        
        func nestedContainer<NestedKey>(
            keyedBy type: NestedKey.Type,
            forKey key: Key
        ) -> KeyedEncodingContainer<NestedKey> {
            return encoder(for: key).container(keyedBy: type)
        }
        
        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            return encoder(for: key).unkeyedContainer()
        }
        
        func superEncoder() -> Swift.Encoder {
            return encoder(for: _ObjectCodingKey.super)
        }
        
        func superEncoder(forKey key: Key) -> Swift.Encoder {
            return encoder(for: key)
        }
    }
    
    private struct _UnkeyedEncodingContainer: UnkeyedEncodingContainer {
        private let encoder: ObjectEncoder.Encoder
        
        private var currentEncoder: _IndexReferencingEncoder {
            defer { encoder.array.append("") }
            return encoder.encoder(at: count)
        }
        
        init(referencing encoder: ObjectEncoder.Encoder) {
            self.encoder = encoder
        }
        
        var codingPath: [CodingKey] {
            return encoder.codingPath
        }
        
        var count: Int {
            return encoder.array.count
        }
        
        func encodeNil() throws {
            try currentEncoder.encodeNil()
        }
        
        func encode<T: CoderPrimitive>(_ value: T) throws {
            try currentEncoder.encode(value)
        }
        
        func encode<T: Encodable>(_ value: T) throws {
            try currentEncoder.encode(value)
        }
        
        func nestedContainer<NestedKey>(
            keyedBy keyType: NestedKey.Type
        ) -> KeyedEncodingContainer<NestedKey> {
            currentEncoder.container(keyedBy: keyType)
        }
        
        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            currentEncoder.unkeyedContainer()
        }
        
        func superEncoder() -> Swift.Encoder {
            currentEncoder
        }
    }
}

extension ObjectEncoder.Encoder: SingleValueEncodingContainer {
    public final func encodeNil() throws {
        assertCanEncodeNewValue()
        
        object = NSNull()
    }
    
    public final func encode<T: CoderPrimitive>(
        _ value: T
    ) throws {
        try _encodePrimitive(value)
    }
    
    private final func _encodePrimitive<T: CoderPrimitive>(
        _ value: T
    ) throws {
        try box(value)
    }
    
    public final func encode<T: Encodable>(
        _ value: T
    ) throws {
        do {
            assertCanEncodeNewValue()
            
            if T.self is any CoderPrimitive.Type {
                let value = value as! any CoderPrimitive
                
                func encode<U: CoderPrimitive>(
                    _ value: U
                ) throws {
                    try self._encodePrimitive(value)
                }
                
                try _openExistential(value, do: encode)
            } else {
                if try !applyStrategy(value) {
                    try value.encode(to: self)
                }
            }
        } catch {
            throw error
        }
    }
    
    private func applyStrategy<T: Encodable>(_ value: T) throws -> Bool {
        if let strategy = options.encodingStrategies[T.self] {
            try strategy.closure(value, self)
        
            return true
        }
        
        return false
    }
    
    private func box<T: Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        
        if try !applyStrategy(value) {
            object = try cast(value, to: NSCoding.self)
        }
    }
    
    /// Asserts that a single value can be encoded at the current coding path
    /// (i.e. that one has not already been encoded through this container).
    /// `preconditionFailure()`s if one cannot be encoded.
    private func assertCanEncodeNewValue() {
        precondition(
            canEncodeNewValue,
            "Attempt to encode value through single value container when previously value already encoded."
        )
    }
}

struct _ObjectCodingKey: CodingKey { // swiftlint:disable:this type_name
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
    
    static let `super` = _ObjectCodingKey(stringValue: "super")!
}

private func _invalidFloatingPointValue<T: FloatingPoint>(_ value: T, at codingPath: [CodingKey]) -> EncodingError {
    let valueDescription: String
    if value == T.infinity {
        valueDescription = "\(T.self).infinity"
    } else if value == -T.infinity {
        valueDescription = "-\(T.self).infinity"
    } else {
        valueDescription = "\(T.self).nan"
    }
    
    let debugDescription = """
    Unable to encode \(valueDescription) directly in JSONObjectEncoder. \
    Use JSONObjectEncoder.NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
    """
    return .invalidValue(value, .init(codingPath: codingPath, debugDescription: debugDescription))
}

extension ObjectEncoder {
    /// The strategy to use for encoding `Data` values.
    public typealias DataEncodingStrategy = EncodingStrategy<Data>
    /// The strategy to use for encoding `Date` values.
    public typealias DateEncodingStrategy = EncodingStrategy<Date>
    
    /// The strategy to use for encoding `Double` values.
    public typealias DoubleEncodingStrategy = EncodingStrategy<Double>
    /// The strategy to use for encoding `Float` values.
    public typealias FloatEncodingStrategy = EncodingStrategy<Float>
}

extension ObjectEncoder.EncodingStrategy {
    /// Encode the `T` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder,
    /// the encoder will encode an empty automatic container in its place.
    public static func custom(_ closure: @escaping Closure) -> ObjectEncoder.EncodingStrategy<T> {
        return .init(closure: closure)
    }
}

extension ObjectEncoder.EncodingStrategy where T == Data {
    /// Defer to `Data` for choosing an encoding.
    public static let deferredToData: ObjectEncoder.DataEncodingStrategy? = nil
    
    /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
    public static let base64 = ObjectEncoder.DataEncodingStrategy.custom {
        try $0.base64EncodedString().encode(to: $1)
    }
}

@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
var iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

extension ObjectEncoder.EncodingStrategy where T == Date {
    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    public static let deferredToDate: ObjectEncoder.DateEncodingStrategy? = nil
    
    /// Encode the `Date` as a UNIX timestamp (as a `Double`).
    public static let secondsSince1970 = ObjectEncoder.DateEncodingStrategy.custom { date, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(date.timeIntervalSince1970)
    }
    
    /// Encode the `Date` as UNIX millisecond timestamp (as a `Double`).
    public static let millisecondsSince1970 = ObjectEncoder.DateEncodingStrategy.custom { date, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(1000.0 * date.timeIntervalSince1970)
    }
    
    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static let iso8601 = ObjectEncoder.DateEncodingStrategy.custom { date, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(iso8601Formatter.string(from: date))
    }
    
    /// Encode the `Date` as a string formatted by the given formatter.
    public static func formatted(_ formatter: DateFormatter) -> ObjectEncoder.DateEncodingStrategy {
        return .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
    }
}

extension ObjectEncoder.EncodingStrategy where T == Decimal {
    public static let compatibleWithJSONEncoder = ObjectEncoder.EncodingStrategy<Decimal>.custom { decimal, encoder in
        encoder.object = NSDecimalNumber(decimal: decimal)
    }
}

extension ObjectEncoder.EncodingStrategy where T == Double {
    public static let throwOnNonConformingFloat = ObjectEncoder.DoubleEncodingStrategy.custom { double, encoder in
        guard !double.isInfinite && !double.isNaN else {
            throw _invalidFloatingPointValue(double, at: encoder.codingPath)
        }
        encoder.object = NSNumber(value: double)
    }
    
    public static func convertNonConformingFloatToString(
        _ positiveInfinity: String,
        _ negativeInfinity: String,
        _ nan: String
    ) -> ObjectEncoder.DoubleEncodingStrategy {
        return .custom { double, encoder in
            if double == .infinity {
                encoder.object = positiveInfinity as NSString
            } else if double == -.infinity {
                encoder.object = negativeInfinity as NSString
            } else if double.isNaN {
                encoder.object = nan as NSString
            } else {
                encoder.object = NSNumber(value: double)
            }
        }
    }
}

extension ObjectEncoder.EncodingStrategy where T == Float {
    public static let throwOnNonConformingFloat = ObjectEncoder.FloatEncodingStrategy.custom { float, encoder in
        guard !float.isInfinite && !float.isNaN else {
            throw _invalidFloatingPointValue(float, at: encoder.codingPath)
        }
        encoder.object = NSNumber(value: float)
    }
    
    public static func convertNonConformingFloatToString(
        _ positiveInfinity: String,
        _ negativeInfinity: String,
        _ nan: String
    ) -> ObjectEncoder.FloatEncodingStrategy {
        return .custom { float, encoder in
            if float == .infinity {
                encoder.object = positiveInfinity as NSString
            } else if float == -.infinity {
                encoder.object = negativeInfinity as NSString
            } else if float.isNaN {
                encoder.object = nan as NSString
            } else {
                encoder.object = NSNumber(value: float)
            }
        }
    }
}

extension ObjectEncoder.EncodingStrategy where T == URL {
    public static let compatibleWithJSONEncoder = ObjectEncoder.EncodingStrategy<URL>.custom { url, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(url.absoluteString)
    }
}

// MARK: - Helpers

extension Encodable {
    fileprivate func encode(
        to encoder: ObjectEncoder,
        userInfo: [CodingUserInfoKey: Any]
    ) throws -> NSCoding {
        try encoder.encode(self, userInfo: userInfo)
    }
}
