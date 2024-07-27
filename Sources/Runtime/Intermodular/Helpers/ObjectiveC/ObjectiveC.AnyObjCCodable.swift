//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct AnyObjCCodable: FailableWrapper {
    public typealias Value = Any
    
    public let value: Value
    
    public var type: TypeMetadata {
        return OpaqueExistentialContainer.withUnretainedValue(value) {
            $0.type
        }
    }
    
    public init(uncheckedValue: Value) {
        self.value = uncheckedValue
    }
    
    public init?(_ value: Value) {
        guard value is ObjCCodable || (try? ObjCTypeEncoding(metatype: Swift.type(of: value))) != nil else {
            return nil
        }
        
        self.init(uncheckedValue: value)
    }
    
    public init(_ value: AnyObject) {
        self.init(uncheckedValue: value)
    }
    
    public init(_ value: ObjCCodable) {
        self.init(uncheckedValue: value)
    }
    
    public init(_ value: AnyObject & ObjCCodable) {
        self.init(uncheckedValue: value)
    }
}

// MARK: - Conformances

extension AnyObjCCodable: CustomStringConvertible {
    public var description: String {
        if let objCTypeEncoding = try? objCTypeEncoding {
            return "\(value) (\(objCTypeEncoding))"
        } else {
            return "\(value) (an error occurred while encoding)"
        }
    }
}

extension AnyObjCCodable: ObjCCodable {
    public var objCTypeEncoding: ObjCTypeEncoding {
        get throws {
            try ObjCTypeEncoding(metatype: self.type.base).unwrap()
        }
    }
    
    public init(
        decodingObjCValueFromRawBuffer buffer: UnsafeMutableRawPointer?,
        encoding: ObjCTypeEncoding
    ) throws {
        let type: TypeMetadata = try TypeMetadata(encoding.toMetatype())
        
        if let buffer = buffer {
            if let type = type.base as? ObjCCodable.Type {
                self.init(uncheckedValue: try type.init(decodingObjCValueFromRawBuffer: buffer, encoding: encoding))
            } else {
                let container = try OpaqueExistentialContainer(copyingBytesOfValueAt: buffer, type: type).unwrap()
                
                self.init(uncheckedValue: container.unretainedValue)
            }
        } else {
            assert(type.isSizeZero)
            
            self.init(uncheckedValue: OpaqueExistentialContainer(uninitialized: type).unretainedValue)
        }
    }
    
    public func encodeObjCValueToRawBuffer() -> UnsafeMutableRawPointer {
        if let value = value as? ObjCCodable {
            return value.encodeObjCValueToRawBuffer()
        } else {
            return OpaqueExistentialContainer.withUnretainedValue(value) {
                $0.encodeObjCValueToRawBuffer()
            }
        }
    }
    
    public func deinitializeRawObjCValueBuffer(_ buffer: UnsafeMutableRawPointer) {
        if let value = value as? ObjCCodable {
            return value.deinitializeRawObjCValueBuffer(buffer)
        } else {
            OpaqueExistentialContainer.withUnretainedValue(value) {
                $0.deinitializeRawObjCValueBuffer(buffer)
            }
        }
    }
}

// MARK: - Auxiliary Extensions-

extension AnyObjCCodable {
    public func _unsafe_cast<T>(to type: T.Type) throws -> T {
        guard TypeMetadata(type).isSizeZero else {
            return unsafeBitCast(())
        }
        
        do {
            return try cast(value)
        } catch {
            if let type = type as? ObjCCodable.Type {
                assert {
                    let layout1 = TypeMetadata(type).memoryLayout
                    let layout2 = TypeMetadata.of(value).memoryLayout
                    
                    return layout1.size == layout2.size
                }
                
                return try withUnsafeRawObjCValueBuffer {
                    try type.init(decodingObjCValueFromRawBuffer: $0, encoding: objCTypeEncoding) as! T
                }
            } else {
                fatalError("Could not cast AnyObjCCodable to \(type)")
            }
        }
    }
}

extension Array where Element == AnyObjCCodable {
    public func combineUnsafeBitCast(to type: TypeMetadata) throws -> OpaqueExistentialContainer {
        return try self
            .map({ .passRetained($0.value) })
            .combineUnsafeBitCast(to: type)
    }
    
    public func combineUnsafeBitCast<T>(to type: T.Type) throws -> T {
        return try combineUnsafeBitCast(to: TypeMetadata(type)).unretainedValue as! T
    }
}
