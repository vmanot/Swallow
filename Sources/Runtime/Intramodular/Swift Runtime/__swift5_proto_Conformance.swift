//
// Copyright (c) Vatsal Manot
//

import MachO
import Foundation
import Swallow

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
    let flags: UInt32
}

@frozen
@usableFromInline
struct _swift_ModuleContextDescriptor {
    let flags: UInt32
    let parent: Int32
    let name: Int32
}

struct _swift_ModuleContext {
    var raw: UnsafeRawPointer
    
    var name: String {
        let typeDescriptor = self.raw.load(as: _swift_ModuleContextDescriptor.self)
        let start = self.raw + MemoryLayout<_swift_ModuleContextDescriptor>.offset(of: \.name)!
        let name = _swift_RelativeDirectPointer<CChar>(offset: typeDescriptor.name)
        
        return name.address(from: start).withMemoryRebound(to: CChar.self, capacity: 1) { pointer in
            return String(cString: pointer)
        }
    }
}

@frozen
@usableFromInline
struct _swift_TypeContextDescriptor {
    let flags: UInt32
    let parent: Int32
    let name: Int32
    let accessor: Int32
}

extension DynamicLinkEditor.Image {
    func _parseSwiftProtocolConformances() -> [__swift5_proto_Conformance] {
        guard let header = UnsafeRawPointer(self.header) else {
            return []
        }
        
        var size: UInt = 0
        let section = header.withMemoryRebound(to: mach_header_64.self, capacity: 1) { pointer in
            getsectiondata(pointer, "__TEXT", "__swift5_proto", &size)
        }
        
        guard let section = section else {
            return []
        }
        
        let rawSection = UnsafeRawPointer(section)
        
        var result: [__swift5_proto_Conformance] = []
        
        for start in stride(from: rawSection, to: rawSection + Int(size), by: MemoryLayout<Int32>.stride) {
            let address = start.load(as: _swift_RelativeDirectPointer<__swift5_proto_Conformance>.self).address(from: start)
            let conformance = __swift5_proto_Conformance(raw: address)
                        
            result.append(conformance)
        }
        
        return result
    }
    
    public func _parseSwiftProtocolConformancesPerType2() -> [_SwiftRuntime.ProtocolConformanceListForType] {
        let conformances = _parseSwiftProtocolConformances()
        
        var result: [TypeMetadata: IdentifierIndexingArrayOf<_SwiftRuntime.ProtocolConformanceListForType.Conformance>] = [:]
        
        for conformance in conformances {
            guard let context = conformance.context, !context.flags.isGeneric else {
                continue
            }
            
            guard let conformanceKind = conformance.kind, conformanceKind != .indirect else {
                continue
            }
            
            guard let typeMetadata = context.metadata() else {
                continue
            }
            
            _ = typeMetadata

            guard let context = conformance.context else {
                continue
            }
            
            guard let type = context.metadata().map({ TypeMetadata($0) }) else {
                continue
            }
            
            let protocolType = conformance.protocol.metadata().map({ TypeMetadata($0) })
            
            result[type, default: []].append(
                .init(
                    conformance: conformance,
                    type: type,
                    typeName: nil,
                    protocolType: protocolType,
                    protocolName: nil
                )
            )
        }
        
        return result.map { key, value in
            _SwiftRuntime.ProtocolConformanceListForType(type: key, conformances: value)
        }
    }
}

@frozen
public struct __swift5_proto_Conformance: Hashable {
    enum Kind: UInt16 {
        case direct = 0x0
        case indirect = 0x1
    }
    
    var raw: UnsafeRawPointer
    
    var `protocol`: _swift_GenericContext {
        let maybeProtocol = _swift_RelativeIndirectablePointer<_swift_GenericContextDescriptor>(
            offset: self.raw.load(as: _swift_ConformanceDescriptor.self).protocol
        )
        return _swift_GenericContext(raw: maybeProtocol.address(from: self.raw))
    }
    
    var kind: Kind? {
        Kind(rawValue: UInt16(self.raw.load(as: _swift_ConformanceDescriptor.self).flags & (0x7 << 3)) >> 3)
    }
    
    var context: _swift_GenericContext? {
        let start = self.raw + MemoryLayout<Int32>.size
        let offset = start.load(as: Int32.self)
        let addr = start + Int(offset)
        
        switch kind {
            case .direct:
                return _swift_GenericContext(raw: addr)
            case .indirect:
                return addr.load(as: _swift_GenericContext.self)
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
        let start = self.raw + MemoryLayout<_swift_TypeContextDescriptor>.offset(of: \.accessor)!
        let accessor = _swift_RelativeDirectPointer<Void>(offset: typeDescriptor.accessor)
        let access = MetadataAccessor(raw: accessor.address(from: start))
        let fn = unsafeBitCast(access.raw, to: (@convention(thin) (Int) -> MetadataResponse).self)
        
        return fn(0).type
    }
}

extension _swift_GenericContext {
    struct MetadataAccessor {
        var raw: UnsafeRawPointer
    }
    
    struct MetadataResponse {
        let type: Any.Type
        let state: Int
    }
}
