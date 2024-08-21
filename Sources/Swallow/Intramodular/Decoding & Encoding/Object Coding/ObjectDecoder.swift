//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct ObjectDecoder: Initiable {
    fileprivate struct Options {
        fileprivate var decodingStrategies = DecodingStrategies()
    }
    
    fileprivate var options = Options()
    
    public init() {
        
    }
    
    public func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from object: Any,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) throws -> T {
        var object = object
        
        if let _object = object as? AnyCodable {
            object = try _object.bridgeToObjectiveC()
        }
        
        do {
            return try ObjectDecoder.Decoder(
                object: object,
                options: options,
                userInfo: userInfo,
                codingPath: []
            )
            .singleValueContainer()
            .decode(type)
        } catch let error as DecodingError {
            throw error
        } catch {
            throw _dataCorrupted(at: [], "The given data was not valid Object.", error)
        }
    }
    
    public struct DecodingStrategy<T: Decodable> {
        public typealias Closure = (Decoder) throws -> T
        
        fileprivate let closure: Closure
        
        public init(closure: @escaping Closure) {
            self.closure = closure
        }
    }
    
    public struct DecodingStrategies {
        var strategies = [ObjectIdentifier: Any]()
        
        public subscript<T>(type: T.Type) -> DecodingStrategy<T>? {
            get {
                strategies[ObjectIdentifier(type)] as? DecodingStrategy<T>
            } set {
                strategies[ObjectIdentifier(type)] = newValue
            }
        }
        
        public init() {
            
        }
    }
    
    /// The strategis to use for decoding values.
    public var decodingStrategies: DecodingStrategies {
        get {
            return options.decodingStrategies
        } set {
            options.decodingStrategies = newValue
        }
    }
}

extension ObjectDecoder {
    public struct Decoder: Swift.Decoder {
        fileprivate typealias Options = ObjectDecoder.Options
        
        public let object: Any
        private let options: Options
        public let codingPath: [CodingKey]
        public let userInfo: [CodingUserInfoKey: Any]
        
        fileprivate init(
            object: Any,
            options: Options,
            userInfo: [CodingUserInfoKey: Any],
            codingPath: [CodingKey]
        ) {
            self.object = object
            self.options = options
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
    }
}

extension ObjectDecoder.Decoder {
    public func container<Key>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
        KeyedDecodingContainer(_KeyedDecodingContainer<Key>(decoder: self, wrapping: try cast()))
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        _UnkeyedDecodingContainer(decoder: self, wrapping: try cast())
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
    
    private func applyStrategy<T: Decodable>(_ type: T.Type) throws -> T? {
        if let strategy = options.decodingStrategies[type] ?? options.decodingStrategies[T.self] {
            return try strategy.closure(self)
        }
        
        return nil
    }
    
    private func cast<T>() throws -> T {
        guard let value = object as? T else {
            if T.self == Swift.Array<Any>.self, let object = object as? [String: Any] {
                let result: Array<Any> = Array(object).flatMap({
                    [$0.key as Any, $0.value as Any]
                })
                
                return result as! T
            }
            
            throw _typeMismatch(at: codingPath, expectation: T.self, reality: object)
        }
        
        return value
    }
    
    // - SeeAlso: https://github.com/apple/swift/pull/11885
    
    private func cast<T: ShouldNotBeDecodedFromBool>() throws -> T {
        if let number = object as? NSNumber {
            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw _typeMismatch(at: codingPath, expectation: NSNumber.self, reality: object)
            }
            
            guard let value = T.init(exactly: number) else {
                throw _dataCorrupted(at: codingPath, "Parsed number <\(number)> does not fit in \(T.self).")
            }
            
            return value
        } else if let value = object as? T {
            return value
        }
        
        throw _typeMismatch(at: codingPath, expectation: T.self, reality: object)
    }
    
    private func cast() throws -> Bool {
        if let number = object as? NSNumber {
            if number === kCFBooleanTrue {
                return true
            } else if number === kCFBooleanFalse {
                return false
            }
            
            throw _typeMismatch(at: codingPath, expectation: type(of: kCFBooleanTrue.self), reality: object)
            
        } else if let bool = object as? Bool {
            return bool
        }
        
        throw _typeMismatch(at: codingPath, expectation: Bool.self, reality: object)
    }
    
    /// create a new `_Decoder` instance referencing `object` as `key` inheriting `userInfo`
    fileprivate func decoder(
        referencing object: Any,
        `as` key: CodingKey
    ) -> ObjectDecoder.Decoder {
        ObjectDecoder.Decoder(
            object: object,
            options: options,
            userInfo: userInfo,
            codingPath: codingPath + [key]
        )
    }
}

private struct _KeyedDecodingContainer<Key: CodingKey> : KeyedDecodingContainerProtocol {
    private let decoder: ObjectDecoder.Decoder
    private let dictionary: [String: Any]
    
    init(decoder: ObjectDecoder.Decoder, wrapping dictionary: [String: Any]) {
        self.decoder = decoder
        self.dictionary = dictionary
    }
    
    var codingPath: [CodingKey] { return decoder.codingPath }
    var allKeys: [Key] {
        return dictionary.keys.compactMap(Key.init)
    }
    func contains(_ key: Key) -> Bool {
        return dictionary[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return try object(for: key) is NSNull
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try decoder(for: key).decode(type)
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try decoder(for: key).decode(type)
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: ShouldNotBeDecodedFromBool {
        return try decoder(for: key).decode(type)
    }
    
    func decode<T: Decodable>(
        _ type: T.Type,
        forKey key: Key
    ) throws -> T {
        try decoder(for: key).decode(type)
    }
    
    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        try decoder(for: key).container(keyedBy: type)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try decoder(for: key).unkeyedContainer()
    }
    
    func superDecoder() throws -> Decoder {
        try decoder(for: _ObjectCodingKey.super)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        try decoder(for: key)
    }
    
    private func object(
        for key: CodingKey
    ) throws -> Any {
        guard let object = dictionary[key.stringValue] else {
            throw _keyNotFound(at: codingPath, key, "No value associated with key \(key) (\"\(key.stringValue)\").")
        }
        
        return object
    }
    
    private func decoder(
        for key: CodingKey
    ) throws -> ObjectDecoder.Decoder {
        decoder.decoder(referencing: try object(for: key), as: key)
    }
}

private struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {
    private let decoder: ObjectDecoder.Decoder
    private let array: [Any]
    
    init(decoder: ObjectDecoder.Decoder, wrapping array: [Any]) {
        self.decoder = decoder
        self.array = array
        self.currentIndex = 0
    }
    
    var codingPath: [CodingKey] {
        return decoder.codingPath
    }
    
    var count: Int? {
        return array.count
    }
    
    var isAtEnd: Bool {
        return currentIndex >= array.count
    }
    
    var currentIndex: Int
    
    mutating func decodeNil() throws -> Bool {
        try throwErrorIfAtEnd(Any?.self)
        if currentObject is NSNull {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    mutating func decode(
        _ type: Bool.Type
    )   throws -> Bool {
        return try currentDecoder {
            try $0.decode(type)
        }
    }
    
    mutating func decode(
        _ type: String.Type
    ) throws -> String {
        return try currentDecoder {
            try $0.decode(type)
        }
    }
    
    mutating func decode<T: ShouldNotBeDecodedFromBool>(
        _ type: T.Type
    ) throws -> T {
        return try currentDecoder {
            try $0.decode(type)
        }
    }
    
    mutating func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T  {
        return try currentDecoder {
            try $0.decode(type)
        }
    }
    
    mutating func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> {
        return try currentDecoder {
            try $0.container(keyedBy: type)
        }
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try currentDecoder {
            try $0.unkeyedContainer()
        }
    }
    
    mutating func superDecoder() throws -> Decoder {
        return try currentDecoder {
            $0
        }
    }
    
    private var currentKey: any CodingKey {
        return _ObjectCodingKey(index: currentIndex)
    }
    
    private var currentObject: Any {
        return array[currentIndex]
    }
    
    private func throwErrorIfAtEnd<T>(
        _ type: T.Type
    ) throws {
        if isAtEnd {
            throw _valueNotFound(at: codingPath + [currentKey], type, "Unkeyed container is at end.")
        }
    }
    
    private mutating func currentDecoder<T>(
        closure: (ObjectDecoder.Decoder) throws -> T
    ) throws -> T {
        try throwErrorIfAtEnd(T.self)
        
        let decoded: T = try closure(decoder.decoder(referencing: currentObject, as: currentKey))
        
        currentIndex += 1
        
        return decoded
    }
}

extension ObjectDecoder.Decoder: SingleValueDecodingContainer {
    public func decodeNil() -> Bool {
        return object is NSNull
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        return try applyStrategy(type) ?? cast()
    }
    
    public func decode(_ type: String.Type) throws -> String {
        return try applyStrategy(type) ?? cast()
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T: ShouldNotBeDecodedFromBool {
        return try applyStrategy(type) ?? cast()
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try applyStrategy(type) ?? type.init(from: self)
    }
}

extension ObjectDecoder {
    /// The strategy to use for decoding `Data` values.
    public typealias DataDecodingStrategy = DecodingStrategy<Data>
    /// The strategy to use for decoding `Date` values.
    public typealias DateDecodingStrategy = DecodingStrategy<Date>
    
    /// The strategy to use for decoding `Double` values.
    public typealias DoubleDecodingStrategy = DecodingStrategy<Double>
    /// The strategy to use for decoding `Float` values.
    public typealias FloatDecodingStrategy = DecodingStrategy<Float>
}

extension ObjectDecoder.DecodingStrategy {
    /// Decode the `T` as a custom value decoded by the given closure.
    public static func custom(_ closure: @escaping Closure) -> ObjectDecoder.DecodingStrategy<T> {
        return .init(closure: closure)
    }
}

extension ObjectDecoder.DecodingStrategy where T == Data {
    /// Defer to `Data` for decoding.
    public static let deferredToData: ObjectDecoder.DataDecodingStrategy? = nil
    
    /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
    public static let base64 = ObjectDecoder.DataDecodingStrategy.custom { decoder in
        guard let data = Data(base64Encoded: try String(from: decoder)) else {
            throw _dataCorrupted(at: decoder.codingPath, "Encountered Data is not valid Base64.")
        }
        return data
    }
}

extension ObjectDecoder.DecodingStrategy where T == Date {
    /// Defer to `Date` for decoding.
    public static let deferredToDate: ObjectDecoder.DateDecodingStrategy? = nil
    
    /// Decode the `Date` as a UNIX timestamp from a `Double`.
    public static let secondsSince1970 = ObjectDecoder.DateDecodingStrategy.custom { decoder in
        Date(timeIntervalSince1970: try Double(from: decoder))
    }
    
    /// Decode the `Date` as UNIX millisecond timestamp from a `Double`.
    public static let millisecondsSince1970 = ObjectDecoder.DateDecodingStrategy.custom { decoder in
        Date(timeIntervalSince1970: try Double(from: decoder) / 1000.0)
    }
    /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static let iso8601 = ObjectDecoder.DateDecodingStrategy.custom { decoder in
        guard let date = iso8601Formatter.date(from: try String(from: decoder)) else {
            throw _dataCorrupted(at: decoder.codingPath, "Expected date string to be ISO8601-formatted.")
        }
        return date
    }
    
    /// Decode the `Date` as a string parsed by the given formatter.
    public static func formatted(_ formatter: DateFormatter) -> ObjectDecoder.DateDecodingStrategy {
        return .custom { decoder in
            guard let date = formatter.date(from: try String(from: decoder)) else {
                throw _dataCorrupted(at: decoder.codingPath, "Date string does not match format expected by formatter.")
            }
            return date
        }
    }
}

extension ObjectDecoder.DecodingStrategy where T == Decimal {
    public static let compatibleWithJSONDecoder = ObjectDecoder.DecodingStrategy<Decimal>.custom { decoder in
        if let decimal = decoder.object as? Decimal {
            return decimal
        } else {
            return Decimal(try Double(from: decoder))
        }
    }
}

extension ObjectDecoder.DecodingStrategy where T == Double {
    public static let deferredToDouble: ObjectDecoder.DoubleDecodingStrategy? = nil
    
    public static func convertNonConformingFloatFromString(
        _ positiveInfinity: String,
        _ negativeInfinity: String,
        _ nan: String
    ) -> ObjectDecoder.DoubleDecodingStrategy {
        return .custom { decoder in
            if let double = decoder.object as? Double {
                return double
            } else if let string = decoder.object as? String {
                if string == positiveInfinity {
                    return .infinity
                } else if string == negativeInfinity {
                    return -.infinity
                } else if string == nan {
                    return .nan
                }
            }
            throw _typeMismatch(at: decoder.codingPath, expectation: Double.self, reality: decoder.object)
        }
    }
}

extension ObjectDecoder.DecodingStrategy where T == Float {
    public static let deferredToFloat: ObjectDecoder.FloatDecodingStrategy? = nil
    
    public static func convertNonConformingFloatFromString(
        _ positiveInfinity: String,
        _ negativeInfinity: String,
        _ nan: String
    ) -> ObjectDecoder.FloatDecodingStrategy {
        return .custom { decoder in
            if let float = decoder.object as? Float {
                return float
            } else if let string = decoder.object as? String {
                if string == positiveInfinity {
                    return .infinity
                } else if string == negativeInfinity {
                    return -.infinity
                } else if string == nan {
                    return .nan
                }
            }
            throw _typeMismatch(at: decoder.codingPath, expectation: Float.self, reality: decoder.object)
        }
    }
}

extension ObjectDecoder.DecodingStrategy where T == URL {
    public static let compatibleWithJSONDecoder = ObjectDecoder.DecodingStrategy<URL>.custom { decoder in
        guard let url = URL(string: try String(from: decoder)) else {
            throw _dataCorrupted(at: decoder.codingPath, "Invalid URL string.")
        }
        return url
    }
}

// MARK: - Internal

func _dataCorrupted(at codingPath: [CodingKey], _ description: String, _ error: Error? = nil) -> DecodingError {
    let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: description,
        underlyingError: error
    )
    return .dataCorrupted(context)
}

private func _keyNotFound(
    at codingPath: [CodingKey],
    _ key: CodingKey,
    _ description: String
) -> DecodingError {
    let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: description
    )
    return.keyNotFound(key, context)
}

private func _valueNotFound(
    at codingPath: [CodingKey],
    _ type: Any.Type,
    _ description: String
) -> DecodingError {
    let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: description
    )
    return .valueNotFound(type, context)
}

private func _typeMismatch(
    at codingPath: [CodingKey],
    expectation: Any.Type,
    reality: Any
) -> DecodingError {
    let description = "Expected to decode \(expectation) but found \(type(of: reality)) instead."
    let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: description
    )
    return .typeMismatch(expectation, context)
}
