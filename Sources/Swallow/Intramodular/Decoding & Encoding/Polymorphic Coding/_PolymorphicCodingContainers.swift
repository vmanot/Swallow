//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

// MARK: - Decoding Containers -

public struct _PolymorphicSingleValueDecodingContainer: SingleValueDecodingContainer {
    private var parent: Decoder
    private var base: SingleValueDecodingContainer
    
    public init(_ base: SingleValueDecodingContainer, parent: Decoder) {
        self.parent = parent
        self.base = base
    }
    
    public var codingPath: [CodingKey] {
        base.codingPath
    }
    
    public func decodeNil() -> Bool {
        base.decodeNil()
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        try base.decode(type)
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        try base.decode(type)
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        try base.decode(type)
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        try base.decode(type)
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        try base.decode(type)
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        try base.decode(type)
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        try base.decode(type)
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try base.decode(type)
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try base.decode(type)
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try base.decode(type)
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try base.decode(type)
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        try base.decode(type)
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        try base.decode(type)
    }
    
    public func decode(_ type: String.Type) throws -> String {
        try base.decode(type)
    }
    
    // This is where the magic happens.
    
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try base.decode(_PolymorphicDecodingProxy<T>.self).value
    }
}

public struct _PolymorphicUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    private var parent: Decoder
    private var base: UnkeyedDecodingContainer
    
    public init(_ base: UnkeyedDecodingContainer, parent: Decoder) {
        self.parent = parent
        self.base = base
    }
    
    public var codingPath: [CodingKey] {
        base.codingPath
    }
    
    public var count: Int? {
        base.count
    }
    
    public var isAtEnd: Bool {
        base.isAtEnd
    }
    
    public var currentIndex: Int {
        base.currentIndex
    }
    
    public mutating func decodeNil() throws -> Bool {
        try base.decodeNil()
    }
    
    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: Int.Type) throws -> Int {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: Float.Type) throws -> Float {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: Double.Type) throws -> Double {
        try base.decode(type)
    }
    
    public mutating func decode(_ type: String.Type) throws -> String {
        try base.decode(type)
    }
    
    public mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try base.decode(_PolymorphicDecodingProxy<T>.self).value
    }
    
    public mutating func decodeIfPresent<T: Decodable>(_ type: T.Type) throws -> T? {
        try base.decodeIfPresent(_PolymorphicDecodingProxy<T>.self)?.value
    }
    
    public mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        .init(_PolymorphicKeyedDecodingContainer(try base.nestedContainer(keyedBy: type), parent: parent))
    }
    
    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        _PolymorphicUnkeyedDecodingContainer(try base.nestedUnkeyedContainer(), parent: parent)
    }
    
    public mutating func superDecoder() throws -> Decoder {
        _PolymorphicDecoder(try base.superDecoder())
    }
}

public struct _PolymorphicKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {    
    private var base: KeyedDecodingContainer<Key>
    private var parent: Decoder
    
    public init(_ base: KeyedDecodingContainer<Key>, parent: Decoder) {
        self.parent = parent
        self.base = base
    }
    
    public var codingPath: [CodingKey] {
        base.codingPath
    }
    
    public var allKeys: [Key] {
        base.allKeys
    }
    
    public func contains(_ key: Key) -> Bool {
        base.contains(key)
    }
    
    public func decodeNil(forKey key: Key) throws -> Bool {
        try base.decodeNil(forKey: key)
    }
    
    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try base.decode(type, forKey: key)
    }
    
    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try base.decode(type, forKey: key)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard !(type is Date.Type) else {
            return try base.decode(T.self, forKey: key)
        }
        
        guard !(type is Optional<Date>.Type) else {
            return try base.decode(T.self, forKey: key)
        }
        
        guard !(type is URL.Type) else {
            return try base.decode(T.self, forKey: key)
        }
        
        guard !(type is Optional<URL>.Type) else {
            return try base.decode(T.self, forKey: key)
        }
        
        guard !(type is Published<URL>.Type) else {
            return try base.decode(T.self, forKey: key)
        }

        guard !(type is Published<Optional<URL>>.Type) else {
            return try base.decode(T.self, forKey: key)
        }
        
        do {
            return try base.decode(_PolymorphicDecodingProxy<T>.self, forKey: key).value
        } catch {
            if let decodingError = _ModularDecodingError(
                error,
                type: T.self,
                data: try base.decodeIfPresent(AnyCodable.self, forKey: key)
            ) {
                throw decodingError
            } else {
                throw error
            }
        }
    }
    
    public func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T?  {
        guard !(type is Data.Type) else {
            return try base.decodeIfPresent(T.self, forKey: key)
        }

        guard !(type is Date.Type) else {
            return try base.decodeIfPresent(T.self, forKey: key)
        }
            
        guard !(type is Optional<Date>.Type) else {
            return try base.decodeIfPresent(T.self, forKey: key)
        }
        
        guard !(type is URL.Type) else {
            return try base.decodeIfPresent(T.self, forKey: key)
        }
        
        guard !(type is Optional<URL>.Type) else {
            return try base.decodeIfPresent(T.self, forKey: key)
        }
        
        return try base.decodeIfPresent(_PolymorphicDecodingProxy<T>.self, forKey: key)?.value
    }
    
    public func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey>  {
        .init(_PolymorphicKeyedDecodingContainer<NestedKey>(try base.nestedContainer(keyedBy: type, forKey: key), parent: parent))
    }
    
    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        _PolymorphicUnkeyedDecodingContainer(try base.nestedUnkeyedContainer(forKey: key), parent: parent)
    }
    
    public func superDecoder() throws -> Decoder {
        _PolymorphicDecoder(try base.superDecoder())
    }
    
    public func superDecoder(forKey key: Key) throws -> Decoder {
        _PolymorphicDecoder(try base.superDecoder(forKey: key))
    }
}

// MARK: - Encoding Containers -

public struct _PolymorphicSingleValueEncodingContainer: SingleValueEncodingContainer {
    private var parent: Encoder
    private var base: SingleValueEncodingContainer
    
    public init(_ base: SingleValueEncodingContainer, parent: Encoder) {
        self.parent = parent
        self.base = base
    }
    
    public var codingPath: [CodingKey] {
        base.codingPath
    }
    
    public mutating func encodeNil() throws {
        try base.encodeNil()
    }
    
    public mutating func encode(_ value: Bool) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int8) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int16) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int32) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int64) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt8) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt16) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt32) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt64) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Float) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Double) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: String) throws {
        try base.encode(value)
    }
    
    public mutating func encode<T: Encodable>(_ value: T) throws {
        try base.encode(value)
    }
}

public struct _PolymorphicUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    private var parent: Encoder
    private var base: UnkeyedEncodingContainer
    
    public init(_ base: UnkeyedEncodingContainer, parent: Encoder) {
        self.parent = parent
        self.base = base
    }
    
    public var codingPath: [CodingKey] {
        base.codingPath
    }
    
    public var count: Int {
        base.count
    }
    
    public mutating func encodeNil() throws {
        try base.encodeNil()
    }
    
    public mutating func encode(_ value: Bool) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int8) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int16) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int32) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Int64) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt8) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt16) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt32) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: UInt64) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Float) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: Double) throws {
        try base.encode(value)
    }
    
    public mutating func encode(_ value: String) throws {
        try base.encode(value)
    }
    
    public mutating func encode<T: Encodable>(_ value: T) throws  {
        try base.encode(value)
    }
    
    // This is where the magic happens.
    
    public mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>  {
        .init(_PolymorphicKeyedEncodingContainer(base.nestedContainer(keyedBy: keyType), parent: parent))
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        _PolymorphicUnkeyedEncodingContainer(base.nestedUnkeyedContainer(), parent: parent)
    }
    
    public mutating func superEncoder() -> Encoder {
        _PolymorphicEncoder(base.superEncoder())
    }
}

public struct _PolymorphicKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    private var base: KeyedEncodingContainer<Key>
    private var parent: Encoder
    
    public init(_ base: KeyedEncodingContainer<Key>, parent: Encoder) {
        self.parent = parent
        self.base = base
    }
    
    public var codingPath: [CodingKey] {
        base.codingPath
    }
    
    public mutating func encodeNil(forKey key: Key) throws {
        try base.encodeNil(forKey: key)
    }
    
    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: Int, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: Int8, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: Int16, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: Int32, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: Int64, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: UInt, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: Float, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: Double, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: String, forKey key: Key) throws {
        try base.encode(value, forKey: key)
    }
    
    public mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        try base.encode(value, forKey: key)
    }
    
    // This is where the magic happens.
    
    public mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        .init(_PolymorphicKeyedEncodingContainer<NestedKey>(base.nestedContainer(keyedBy: keyType, forKey: key), parent: parent))
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        _PolymorphicUnkeyedEncodingContainer(base.nestedUnkeyedContainer(forKey: key), parent: parent)
    }
    
    public mutating func superEncoder() -> Encoder {
        _PolymorphicEncoder(base.superEncoder())
    }
    
    public mutating func superEncoder(forKey key: Key) -> Encoder {
        _PolymorphicEncoder(base.superEncoder(forKey: key))
    }
}
