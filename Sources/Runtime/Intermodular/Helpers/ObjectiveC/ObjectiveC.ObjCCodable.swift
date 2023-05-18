//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public protocol ObjCCodable {
    var objCTypeEncoding: ObjCTypeEncoding { get }
    
    init(decodingObjCValueFromRawBuffer _: UnsafeMutableRawPointer?, encoding: ObjCTypeEncoding)
     
    func encodeObjCValueToRawBuffer() -> UnsafeMutableRawPointer
    func deinitializeRawObjCValueBuffer(_: UnsafeMutableRawPointer)
}

// MARK: - Conformances

extension ObjCCodable {
    public func deinitializeRawObjCValueBuffer(_: UnsafeMutableRawPointer) {

    }
}

extension ObjCTypeEncodable where Self: ObjCCodable {
    public var objCTypeEncoding: ObjCTypeEncoding {
        return Self.objCTypeEncoding
    }
}

extension Trivial where Self: ObjCCodable {
    public init(decodingObjCValueFromRawBuffer buffer: UnsafeMutableRawPointer?, encoding: ObjCTypeEncoding) {
        if let buffer = buffer {
            self = buffer.assumingMemoryBound(to: Self.self).pointee // FIXME: ?
        } else {
            assert(encoding.isSizeZero)
            
            self = unsafeBitCast(())
        }
    }
    
    public func encodeObjCValueToRawBuffer() -> UnsafeMutableRawPointer {
        .initializing(from: bytes)
    }
}

// MARK: - Extensions

extension ObjCCodable {
    public func withUnsafeRawObjCValueBuffer<Result>(_ body: ((UnsafeMutableRawPointer) throws -> Result)) rethrows -> Result {
        let buffer = encodeObjCValueToRawBuffer()
        defer {
            deinitializeRawObjCValueBuffer(buffer)
            buffer.deallocate()
        }
        return try body(buffer)
    }
}
