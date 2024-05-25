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
        guard value is ObjCCodable || ObjCTypeEncoding(metatype: Swift.type(of: value)) != nil else {
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
        return "\(value) (\(objCTypeEncoding))"
    }
}

extension AnyObjCCodable: ObjCCodable {
    public var objCTypeEncoding: ObjCTypeEncoding {
        return ObjCTypeEncoding(metadata: type)!
    }

    public init(
        decodingObjCValueFromRawBuffer buffer: UnsafeMutableRawPointer?,
        encoding: ObjCTypeEncoding
    ) {
        let type = encoding.toTypeMetadata()

        if let buffer = buffer {
            if let type = type.base as? ObjCCodable.Type {
                self.init(uncheckedValue: type.init(decodingObjCValueFromRawBuffer: buffer, encoding: encoding))
            } else {
                self.init(uncheckedValue: OpaqueExistentialContainer(copyingBytesOfValueAt: buffer, type: type).unretainedValue)
            }
        } else {
            assert(type.isSizeZero)

            self.init(uncheckedValue: OpaqueExistentialContainer(unitialized: type).unretainedValue)
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
    public func _unsafe_cast<T>(to type: T.Type) -> T {
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

                return withUnsafeRawObjCValueBuffer {
                    type.init(decodingObjCValueFromRawBuffer: $0, encoding: objCTypeEncoding) as! T
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
