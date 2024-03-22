//
// Copyright (c) Vatsal Manot
//

import Swift

/// https://github.com/apple/swift/blob/f2c42509628bed66bf5b8ee02fae778a2ba747a1/include/swift/Reflection/Records.h#L160

@frozen
@usableFromInline
struct SwiftRuntimeFieldDescriptor {
    enum Kind: UInt16 {
        case `struct` = 0
        case `class` = 1
        case `enum` = 2
        case multiPayloadEnum = 3
        case `protocol` = 4
        case classProtocol = 5
        case objcProtocol = 6
        case objcClass = 7
    }

    var mangledTypeNameOffset: Int32
    var superClassOffset: Int32
    var _kind: UInt16
    var fieldRecordSize: Int16
    var numFields: Int32
    var fields: SwiftRuntimeUnsafeRelativeVector<FieldRecord>
    
    var kind: Kind {
        Kind(rawValue: _kind)!
    }
}

@frozen
@usableFromInline
struct FieldRecord {
    private var fieldRecordFlags: Int32
    private var _mangledTypeName: SwiftRuntimeUnsafeRelativePointer<Int32, Int8>
    private var _fieldName: SwiftRuntimeUnsafeRelativePointer<Int32, UInt8>
    
    @_transparent
    var isVariable: Bool {
        (fieldRecordFlags & 0x2) == 0x2
    }
    
    @_transparent
    mutating func fieldName() -> String {
        String(cString: _fieldName.advanced())
    }
    
    @_transparent
    mutating func mangedTypeName() -> String {
        String(cString: _mangledTypeName.advanced())
    }
    
    @_transparent
    mutating func type(
        genericContext: UnsafeRawPointer?,
        genericArguments: UnsafeRawPointer?
    ) -> Any.Type {
        let typeName = _mangledTypeName.advanced()
        
        let metadataPtr = _swift_getTypeByMangledNameInContext(
            typeName,
            getSymbolicMangledNameLength(typeName),
            genericContext: genericContext,
            genericArguments: genericArguments
        )
        
        return unsafeBitCast(metadataPtr, to: Any.Type.self)
    }
    
    @_transparent
    private func getSymbolicMangledNameLength(
        _ base: UnsafeRawPointer
    ) -> Int32 {
        var end = base
        
        while let current = Optional(end.load(as: UInt8.self)), current != 0 {
            end += 1
            if current >= 0x1 && current <= 0x17 {
                end += 4
            } else if current >= 0x18 && current <= 0x1F {
                end += MemoryLayout<Int>.size
            }
        }
        
        return Int32(end - base)
    }
}
