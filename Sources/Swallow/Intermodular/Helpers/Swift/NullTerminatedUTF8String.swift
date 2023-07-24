//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public struct NullTerminatedUTF8String: MutableWrapper {
    public typealias Value = UnsafeMutablePointer<CChar>
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

extension NullTerminatedUTF8String {
    public struct Iterator {
        public var base: NullTerminatedUTF8String
        
        public init(base: NullTerminatedUTF8String) {
            self.base = base
        }
    }
}

// MARK: - Extensions

extension NullTerminatedUTF8String {
    public var stringValue: String {
        return String(utf8String: self, managed: false)
    }
}

// MARK: - Conformances

extension NullTerminatedUTF8String: CustomStringConvertible {
    public var description: String {
        String(describing: stringValue)
    }
}

extension NullTerminatedUTF8String: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stringValue)
    }
    
    public static func == (lhs: NullTerminatedUTF8String, rhs: NullTerminatedUTF8String) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension NullTerminatedUTF8String.Iterator: IteratorProtocol {
    public typealias Element = CChar
    
    public mutating func next() -> Element? {
        guard base[0] != 0 else {
            return nil
        }
        
        defer {
            base.advance()
        }
        
        return base.pointee
    }
}

extension NullTerminatedUTF8String: MutableCollection {
    public typealias Element = Iterator.Element
    public typealias Index = Int
    
    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        return .init(strlen(value))
    }
    
    public subscript(index: Index) -> Element {
        get {
            return value[index]
        }
        
        nonmutating set {
            value[index] = newValue
        }
    }
}

extension NullTerminatedUTF8String: MutablePointer {
    public typealias Pointee = Value.Pointee
    public typealias Stride = Value.Stride
    
    public var opaquePointerRepresentation: OpaquePointer {
        value.opaquePointerRepresentation
    }
    
    public init(_ pointer: OpaquePointer) {
        self.init(Value(pointer))
    }
    
    public init?(_ pointer: OpaquePointer?) {
        guard let pointer = pointer else {
            return nil
        }
        
        self.init(pointer)
    }
    
    public func distance(to other: NullTerminatedUTF8String) -> Value.Stride {
        value.distance(to: other.value)
    }
    
    public func advanced(by n: Value.Stride) -> NullTerminatedUTF8String {
        .init(value.advanced(by: n))
    }
    
    public static func allocate(capacity: Stride) -> NullTerminatedUTF8String {
        let resultValue = Value.allocate(capacity: capacity + 1)
        resultValue[capacity] = 0
        return .init(resultValue)
    }
}

extension NullTerminatedUTF8String: Sequence {
    public func makeIterator() -> Iterator {
        .init(base: self)
    }
}

// MARK: - Helpers

extension String {
    public init(cString: NullTerminatedUTF8String) {
        self = cString.stringValue
    }
}
