//
// Copyright (c) Vatsal Manot
//

import Swallow

protocol OpaqueExistentialContainerInterface {
    
}

extension OpaqueExistentialContainerInterface {
    static func retainValue(at address: UnsafeRawPointer?) {
        if let address = address {
            let buffer = UnsafeMutablePointer<Self>.allocate(capacity: 1)
            
            buffer.initialize(to: address.assumingMemoryBound(to: Self.self).pointee)
            buffer.deallocate()
        } else {
            assert(TypeMetadata(self).isSizeZero)
        }
    }
    
    static func withUnsafeBytesOfValue<T>(
        of value: Any,
        _ body: ((UnsafeRawBufferPointer) throws -> T)
    ) rethrows -> T {
        var _value = value as! Self
        
        return try withUnsafeBytes(of: &_value, body)
    }
    
    static func withUnsafeMutableBytesOfValue<T>(
        of value: inout Any,
        _ body: ((UnsafeMutableRawBufferPointer) throws -> T)
    ) rethrows -> T {
        var _value = value as! Self
        
        defer {
            value = _value
        }
        
        return try withUnsafeMutableBytes(of: &_value, body)
    }
    
    static func copyValue(
        from address: UnsafeRawPointer?
    ) -> Any? {
        if let address: UnsafeRawPointer = address {
            if swift_isClassType(self) {
                guard address.assumingMemoryBound(to: Optional<AnyObject>.self).pointee != nil else {
                    return nil
                }
            }
            
            return address.assumingMemoryBound(to: Self.self).pointee
        } else {
            let type = TypeMetadata(self)
            
            assert(type.isSizeZero)
            
            return nil
        }
    }
    
    static func update(_ address: UnsafeMutableRawPointer?, to value: Any) {
        if let address = address {
            address.assumingMemoryBound(to: self).update(to: value as! Self)
        } else {
            assert(TypeMetadata(self).isSizeZero)
        }
    }
    
    static func initializeValue(at address: UnsafeMutableRawPointer?, to value: Any) {
        if let address = address {
            address.assumingMemoryBound(to: self).initialize(to: value as! Self)
        } else {
            assert(TypeMetadata(self).isSizeZero)
        }
    }
    
    static func reinitializeValue(at address: UnsafeMutableRawPointer?, to value: Any) {
        if let address = address {
            address.assumingMemoryBound(to: self).reinitialize(to: value as! Self)
        } else {
            assert(TypeMetadata.of(self).isSizeZero)
        }
    }
    
    static func writeValue(_ value: Any, to address: UnsafeMutableRawPointer) {
        address.assumingMemoryBound(to: Self.self).pointee = value as! Self
    }
    
    static func deinitializeValue(at address: UnsafeMutableRawPointer) {
        address.assumingMemoryBound(to: self).deinitialize(count: 1)
    }
}

// MARK: - Helpers

extension OpaqueExistentialContainer {
    public init?<ByteAddress: RawPointer>(
        copyingBytesOfValueAt address: ByteAddress?,
        type: TypeMetadata
    ) {
        if type.memoryLayout.size == 0 {
            assert(address == nil)
            
            self.init(uninitialized: type)
        } else {
            guard let value: Any = type.opaqueExistentialInterface.copyValue(from: address!.rawRepresentation) else {
                return nil
            }
            
            self = .passUnretained(value)
        }
    }
    
    public init?<Bytes: RawBufferPointer>(
        copyingBytesOfValueFrom bytes: Bytes,
        type: TypeMetadata
    ) {
        self.init(copyingBytesOfValueAt: bytes.baseAddress, type: type)
    }
    
    public init?(
        type: TypeMetadata,
        unsafeBytesOfValueInitializer: (UnsafeMutableRawBufferPointer) -> ()
    ) {
        let bytes = UnsafeMutableRawBufferPointer.allocate(for: type)
        
        unsafeBytesOfValueInitializer(bytes)
        
        self.init(copyingBytesOfValueAt: bytes.baseAddress, type: type)
        
        bytes.deallocate()
    }
    
    public func updateValue(
        at address: UnsafeMutableRawPointer?
    ) {
        if let address = address {
            type.opaqueExistentialInterface
                .initializeValue(at: address, to: unretainedValue)
        } else {
            assert(type.isSizeZero)
        }
        
        release()
    }
    
    public func initializeValue(
        at address: UnsafeMutableRawPointer?
    ) {
        if let address = address {
            type.opaqueExistentialInterface
                .initializeValue(at: address, to: unretainedValue)
        } else {
            assert(type.isSizeZero)
        }
    }
    
    public func reintializeValue(
        at address: UnsafeMutableRawPointer?
    ) {
        if let address = address {
            type.opaqueExistentialInterface
                .reinitializeValue(at: address, to: unretainedValue)
        } else {
            assert(type.isSizeZero)
        }
    }
    
    public func withUnsafeBytesOfValue<T>(
        _ body: ((UnsafeRawBufferPointer) throws -> T)
    ) rethrows -> T {
        return try type
            .opaqueExistentialInterface
            .withUnsafeBytesOfValue(of: unretainedValue, body)
    }
    
    public mutating func withUnsafeMutableBytesOfValue<T>(
        _ body: ((UnsafeMutableRawBufferPointer) throws -> T)
    ) rethrows -> T {
        return try type
            .opaqueExistentialInterface
            .withUnsafeMutableBytesOfValue(of: &unretainedValue, body)
    }
    
    public mutating func deinitializeValue() {
        let interface = type.opaqueExistentialInterface
        
        withUnsafeMutableBytesOfValue {
            interface.deinitializeValue(at: $0.baseAddress!)
        }
    }
}

extension OpaqueExistentialContainer: UnmanagedProtocol {
    public typealias Instance = Any
    
    public static func passUnretained(_ value: Instance) -> OpaqueExistentialContainer {
        if Swift.type(of: value) is AnyClass {
            let type = TypeMetadata.of(value)
            let buffer = Buffer((unsafeBitCast(try! cast(value, to: AnyObject.self)), nil, nil))
            
            return OpaqueExistentialContainer(buffer: buffer, type: type)
        } else {
            var result = unsafeBitCast(value, to: OpaqueExistentialContainer.self)
            
            guard result.type.base != Any.self else {
                result = unsafeBitCast(__fixed_opaqueExistential(value), to: OpaqueExistentialContainer.self)
                
                assert(result.type.base != Any.self)
                
                return result
            }
            
            return result
        }
    }
    
    public func takeUnretainedValue() -> Instance {
        return unsafeBitCast(self, to: Any.self)
    }
    
    @discardableResult
    public func retain() -> OpaqueExistentialContainer {
        withUnsafeBytesOfValue {
            type.opaqueExistentialInterface.retainValue(at: $0.baseAddress)
        }
        
        return self
    }
    
    public func release() {
        var value: Any = _strictlyUnoptimized_passOpaqueExistential(()) // this (reasonably) assumes Void.Type isn't be heap-allocated
        
        Swift.withUnsafeMutableBytes(of: &value) {
            $0.baseAddress?.assumingMemoryBound(to: Self.self).pointee = self
        }
    }
}

extension TypeMetadata {
    var opaqueExistentialInterface: OpaqueExistentialContainerInterface.Type {
        struct ProtocolTypeContainer {
            let type: Any.Type
            let witnessTable: Int
        }
        
        let container = ProtocolTypeContainer(type: base, witnessTable: 0)
        
        let interface = unsafeBitCast(container, to: OpaqueExistentialContainerInterface.Type.self)
        
        assert(interface as Any.Type == base)
        
        return interface
    }
}
