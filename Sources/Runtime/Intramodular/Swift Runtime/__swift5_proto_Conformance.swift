//
// Copyright (c) Vatsal Manot
//

import MachO
import Foundation
import Swallow

@frozen
public struct __swift5_proto_Conformance: Hashable {
    enum Kind: UInt16 {
        case direct = 0x0
        case indirect = 0x1
    }
    
    var raw: UnsafeRawPointer
    
    var descriptor: _swift_ConformanceDescriptor {
        self.raw.load(as: _swift_ConformanceDescriptor.self)
    }
    
    var `protocol`: _swift_GenericContext? {
        let maybeProtocol = _swift_RelativeIndirectablePointer<_swift_GenericContextDescriptor>(
            offset: descriptor.protocol
        )
        
        let address: UnsafeRawPointer = maybeProtocol.address(from: self.raw)
                
        if unsafeBitCast(address, to: Optional<UnsafeRawPointer>.self) == nil {
            return nil
        }
        
        return _swift_GenericContext(raw: address)
    }
    
    var type: Any.Type? {
        guard let contextDescriptor else {
            return nil
        }
        
        let maybeType = _swift_RelativeIndirectablePointer<_swift_GenericContext>(
            offset: descriptor.typeRef
        )
        
        guard let kind, kind != .IndirectTypeDescriptor else {
            return nil
        }
        
        let typeDescriptor = maybeType.address(from: raw)
            .advanced(by: MemoryLayout<_swift_ConformanceDescriptor>.offset(of: \.typeRef)!)
            .advanced(by: Int(descriptor.typeRef))
            .load(as: _swift_TypeContextDescriptor.self)
        
        let start = self.raw + MemoryLayout<_swift_TypeContextDescriptor>.offset(of: \.fieldTypesAccessor)!
        let accessor = _swift_RelativeDirectPointer<Void>(offset: typeDescriptor.fieldTypesAccessor.offset)
        
        let accessFunction = unsafeBitCast(accessor.address(from: start), to: (@convention(c) () -> UInt64).self)
        
        guard contextDescriptor.flags.isGeneric else {
            return nil
        }
        
        return unsafeBitCast(accessFunction(), to: Any.Type.self)
    }
    
    var kind: SwiftRuntimeTypeReferenceKind? {
        descriptor.flags.kind
    }
    
    var contextDescriptor: _swift_GenericContext? {
        let start = self.raw + MemoryLayout<Int32>.size
        let offset = start.load(as: Int32.self)
        let addr = start + Int(offset)
        
        switch kind {
            case .DirectTypeDescriptor:
                return _swift_GenericContext(raw: addr)
            case .IndirectTypeDescriptor:
                return addr.load(as: _swift_GenericContext.self)
            case .DirectObjCClassName:
                return nil
            case .IndirectObjCClass:
                return nil
            case nil:
                return nil
        }
    }
}

struct _swift_GenericContext: Hashable {
    struct Flags: OptionSet {
        var rawValue: UInt32
        
        var kind: _swift_GenericContext.Kind? {
            return _swift_GenericContext.Kind(rawValue: UInt8(self.rawValue & 0x1F))
        }
        
        @usableFromInline
        var version: UInt8 {
            UInt8((rawValue >> 0x8) & 0xFF)
        }
        
        @usableFromInline
        var kindSpecificFlags: UInt16 {
            UInt16((rawValue >> 0x10) & 0xFFFF)
        }
        
        @usableFromInline
        var isGeneric: Bool {
            UInt8(rawValue & 0x80) != 0
        }
    }
    
    enum Kind: UInt8 {
        case `class` = 0x11
        case `struct` = 0x12
        case `enum` = 0x13
    }
    
    struct MetadataAccessor {
        var raw: UnsafeRawPointer
    }
    
    struct MetadataResponse {
        let type: Any.Type
        let state: Int
    }
    
    var raw: UnsafeRawPointer
    
    var parent: _swift_GenericContext? {
        let parent = _swift_RelativeIndirectablePointer<_swift_GenericContextDescriptor>(
            offset: self.raw.load(as: _swift_GenericContextDescriptor.self).parent
        )
        
        guard parent.offset != 0 else {
            return nil
        }
        
        let start = self.raw + MemoryLayout<Int32>.size
        return Self(raw: parent.address(from: start))
    }
    
    var moduleDescriptor: _swift_ModuleContext {
        var result = self
        
        while let parent = result.parent {
            result = parent
        }
        
        return _swift_ModuleContext(raw: result.raw)
    }
    
    var flags: Flags {
        Self.Flags(rawValue: self.raw.load(as: _swift_GenericContextDescriptor.self).flags)
    }
    
    func metadata() -> Any.Type? {
        guard flags.kind != nil else {
            return nil
        }
        
        let typeDescriptor = self.raw.load(as: _swift_TypeContextDescriptor.self)
        let start = self.raw + MemoryLayout<_swift_TypeContextDescriptor>.offset(of: \.fieldTypesAccessor.offset)!
        let accessor = _swift_RelativeDirectPointer<Void>(offset: typeDescriptor.fieldTypesAccessor.offset)
        let access = MetadataAccessor(raw: accessor.address(from: start))
        let fn = unsafeBitCast(access.raw, to: (@convention(thin) (Int) -> MetadataResponse).self)
        
        let result: Any.Type = fn(0).type
        
        return result
    }
}

@frozen
@usableFromInline
struct _swift_GenericContextDescriptor {
    let flags: UInt32
    let parent: Int32
}

@frozen
@usableFromInline
struct _swift_ConformanceDescriptor {
    let `protocol`: Int32
    let typeRef: Int32
    let witnessTablePattern: Int32
    let flags: SwiftRuntimeProtocolConformanceDescriptor.ConformanceFlags
}

@_spi(Internal)
@frozen
public struct _swift_ModuleContextDescriptor {
    public let flags: SwiftRuntimeContextDescriptorFlags
    public let parent: Int32
    public let name: Int32
}

struct _swift_ModuleContext {
    var raw: UnsafeRawPointer
    
    var contextDescriptor: _swift_ModuleContextDescriptor {
        self.raw.load(as: _swift_ModuleContextDescriptor.self)
    }
    
    var name: String {
        let start = self.raw + MemoryLayout<_swift_ModuleContextDescriptor>.offset(of: \.name)!
        let name = _swift_RelativeDirectPointer<CChar>(offset: contextDescriptor.name)
        
        return name.address(from: start).withMemoryRebound(to: CChar.self, capacity: 1) { pointer in
            return String(cString: pointer)
        }
    }
}

@_spi(Internal)
@frozen
public struct _swift_TypeContextDescriptor {
    public var flags: SwiftRuntimeContextDescriptorFlags
    public var parent: Int32
    public var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    public var fieldTypesAccessor: SwiftRuntimeUnsafeRelativePointer<Int32, Int>
}

public struct _swift_TypeConformanceList: Identifiable {
    @frozen
    public struct Conformance: Hashable, Identifiable {
        @usableFromInline
        var conformance: __swift5_proto_Conformance?
        
        public var type: TypeMetadata?
        public let typeName: String?
        public let protocolType: TypeMetadata?
        public let protocolName: String?
        
        public var id: AnyHashable {
            if let conformance {
                return conformance.hashValue
            } else {
                return hashValue
            }
        }
        
        init(
            conformance: __swift5_proto_Conformance?,
            type: TypeMetadata? = nil,
            typeName: String?,
            protocolType: TypeMetadata? = nil,
            protocolName: String?
        ) {
            self.conformance = conformance
            self.type = type
            self.typeName = typeName
            self.protocolType = protocolType
            self.protocolName = protocolName
        }
    }
    
    public let type: TypeMetadata?
    public var conformances: IdentifierIndexingArrayOf<Conformance>
    
    public var isEmpty: Bool {
        conformances.isEmpty
    }
    
    public var id: AnyHashable {
        type
    }
}
