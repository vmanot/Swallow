//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@frozen
public struct OpaqueExistentialContainer: CustomDebugStringConvertible {
    @frozen
    public struct Buffer: Wrapper, @unchecked Sendable, Trivial{
        public typealias Value = (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?)
        
        public var pointer0: UnsafeMutableRawPointer?
        public var pointer1: UnsafeMutableRawPointer?
        public var pointer2: UnsafeMutableRawPointer?
        
        public var value: (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) {
            (pointer0, pointer1, pointer2)
        }
        
        @_transparent
        public init(_ value: Value) {
            self.pointer0 = value.0
            self.pointer1 = value.1
            self.pointer2 = value.2
        }
        
        @_transparent
        public init() {
            self.init((nil, nil, nil))
        }
    }
    
    public enum Error: Swift.Error {
        case runtimeCastError
    }
    
    public static var existentialHeaderSize: Int {
        if CPU.Architecture.is64Bit {
            return 16
        } else {
            return 8
        }
    }
    
    public var buffer: Buffer
    public var type: TypeMetadata
    
    @_transparent
    public init(buffer: Buffer, type: TypeMetadata) {
        self.buffer = buffer
        self.type = type
    }
    
    @_transparent
    public init(uninitialized type: TypeMetadata) {
        self.init(buffer: Buffer(), type: type)
    }
}

// MARK: - Extensions

extension OpaqueExistentialContainer {
    public func getUnretainedValue<T>() -> T {
        precondition(type.base == T.self)
        
        return unretainedValue as! T
    }
}

// MARK: - Conformances

extension OpaqueExistentialContainer: MutableContiguousStorage {
    public typealias Element = Byte
    
    public func withBufferPointer<BP: InitiableBufferPointer, T>(
        _ body: ((BP) throws -> T)
    ) rethrows -> T where Element == BP.Element {
        var container = self
        
        return try container.withMutableBufferPointer({ try body($0) })
    }
    
    // TODO: Optimize, especially the `type.kind == .existential` case.
    public mutating func withMutableBufferPointer<BP: InitiableBufferPointer, T>(
        _ body: ((BP) throws -> T)
    ) rethrows -> T where Element == BP.Element {
        assert(MemoryLayout<BP.BaseAddressPointer.Pointee>.size == MemoryLayout<Byte>.size)
        
        let result: T
        
        if type.kind == .class {
            let classType: AnyClass = type.base as! AnyClass
                        
            result = try body(BP(start: buffer.value.0, count: class_getInstanceSize(classType)))
        } else if type.kind == .struct || type.kind == .tuple {
            if type.memoryLayout.size > MemoryLayout<Buffer>.size {
                result = try body(BP(start: buffer.value.0?.advanced(by: OpaqueExistentialContainer.existentialHeaderSize), count: type.memoryLayout.size))
            } else {
                result = try buffer.withUnsafeMutableBytes({ try body(BP(start: $0.baseAddress, count: type.memoryLayout.size)) })
            }
        } else if type.kind == .existential {
            var _value = self.takeUnretainedValue()
            
            let result = try type.opaqueExistentialInterface.withUnsafeMutableBytesOfValue(of: &_value) {
                try body(.init($0))
            }
            
            self = .passUnretained(_value)
            
            return result
        } else {
            fatalError("unsupported kind: \(type.kind)")
        }
        
        return result
    }
}

extension OpaqueExistentialContainer: ObjCCodable {
    public var objCTypeEncoding: ObjCTypeEncoding {
        get throws {
            try ObjCTypeEncoding(metatype: type.base) ?? .unknown
        }
    }
    
    public init(
        decodingObjCValueFromRawBuffer buffer: UnsafeMutableRawPointer?,
        encoding: ObjCTypeEncoding
    ) throws {
        let type = try TypeMetadata(encoding.toMetatype())
        
        if let buffer = buffer {
            if let type = type.base as? ObjCCodable.Type {
                self = .passUnretained(
                    try type.init(
                        decodingObjCValueFromRawBuffer: buffer,
                        encoding: encoding
                    )
                )
            } else {
                self = try Self(copyingBytesOfValueAt: buffer, type: type).unwrap()
            }
        } else {
            assert(encoding.isSizeZero)
            
            self.init(uninitialized: type)
        }
    }
    
    public func encodeObjCValueToRawBuffer() -> UnsafeMutableRawPointer {
        if type.base is AnyClass {
            return UnsafePointer
                .allocate(initializingTo: unsafeBitCast(buffer.value.0!, to: AnyObject.self))
                .mutableRawRepresentation
        } else if let value = takeUnretainedValue() as? ObjCCodable {
            return value.encodeObjCValueToRawBuffer()
        } else {
            return withUnsafeBytes({ UnsafeMutableRawBufferPointer.initializing(from: $0) }).baseAddress!
        }
    }
    
    public func deinitializeRawObjCValueBuffer(_ buffer: UnsafeMutableRawPointer) {
        if type.base is AnyClass {
            buffer.assumingMemoryBound(to: AnyObject.self).deinitialize(count: 1)
        }
    }
}

// MARK: - Auxiliary Extensions

extension Array where Element == OpaqueExistentialContainer {
    public func combineCast(
        to type: TypeMetadata
    ) throws -> OpaqueExistentialContainer {
        if count == 0 && type.memoryLayout.size == 0 {
            return OpaqueExistentialContainer(uninitialized: type)
        } else if count == 1 && self[0].type == type {
            return self[0]
        } else if let tuple = TypeMetadata.Tuple(type.base), tuple.fields.map({ $0.type }) == map({ $0.type }) {
            let result = OpaqueExistentialContainer(type: type) { bytes in
                var offset = 0
                for element in self {
                    element.updateValue(at: bytes.baseAddress?.advanced(by: offset))
                    offset += element.type.memoryLayout.size
                }
            }
            
            guard let result else {
                throw OpaqueExistentialContainer.Error.runtimeCastError
            }
            
            return result
        } else {
            throw OpaqueExistentialContainer.Error.runtimeCastError
        }
    }
    
    public func combineUnsafeBitCast(
        to type: TypeMetadata
    ) throws -> OpaqueExistentialContainer {
        if count == 0 && type.memoryLayout.size == 0 {
            return OpaqueExistentialContainer(uninitialized: type)
        } else if count == 1 && self[0].type.memoryLayout == type.memoryLayout {
            return self[0]
        } else if let tuple = TypeMetadata.Tuple(type.base), tuple.fields.map({ $0.type.memoryLayout }) == map({ $0.type.memoryLayout }) {
            let result = OpaqueExistentialContainer(type: type) { bytes in
                var offset = 0
                for element in self {
                    element.updateValue(at: bytes.baseAddress?.advanced(by: offset))
                    offset += element.type.memoryLayout.size
                }
            }
            
            guard let result else {
                throw OpaqueExistentialContainer.Error.runtimeCastError
            }
            
            return result
        } else {
            throw OpaqueExistentialContainer.Error.runtimeCastError
        }
    }
}
