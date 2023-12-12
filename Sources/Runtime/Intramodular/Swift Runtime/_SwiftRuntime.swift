//
// Copyright (c) Vatsal Manot
//

import MachO
import Diagnostics
import Foundation
import Swallow

public struct _SwiftRuntime {
    
}


extension _SwiftRuntime {
    @frozen
    public struct _TypeConformance: Hashable, Identifiable {
        public let name: String
        @_HashableExistential
        public var type: Any.Type?
        public let `protocol`: String
        
        public var id: AnyHashable {
            hashValue
        }

        public init(
            name: String,
            type: Any.Type?,
            `protocol`: String
        ) {
            self.name = name
            self.type = type
            self.protocol = `protocol`
        }
    }
    
    public struct _TypeConformances: Identifiable {
        public let name: String
        public let conformances: IdentifierIndexingArrayOf<_TypeConformance>
        
        public var id: AnyHashable {
            name
        }
    }
    
    public static func types(
        for image: DynamicLinkEditor.Image
    ) -> [_TypeConformances] {
        var result = [String: [_TypeConformance]]()
        
        var sectionSize: UInt = 0
        let sectStart = UnsafeRawPointer(
            getsectiondata(
                UnsafeRawPointer(image.header).assumingMemoryBound(to: mach_header_64.self),
                "__TEXT",
                "__swift5_proto",
                &sectionSize
            )
        )?.assumingMemoryBound(to: Int32.self)

        guard var sectData = sectStart else {
            return []
        }
        
        for _ in 0..<(Int(sectionSize) / MemoryLayout<Int32>.size) {
            let conformance = UnsafeRawPointer(sectData)
                .advanced(by: Int(sectData.pointee))
                .assumingMemoryBound(to: SwiftRuntimeProtocolConformanceDescriptor.self)
            
            if let type = parseConformance(from: conformance) {
                result[type.name, default: []].append(type)
            }
            
            sectData = sectData.successor()
        }
        
        return result.filter({ !$0.value.isEmpty }).map {
            _TypeConformances(
                name: $0.value.first!.name,
                conformances: IdentifierIndexingArrayOf($0.value.distinct())
            )
        }
    }
        
    private static func parseConformance(
        from conformanceDescriptor: UnsafePointer<SwiftRuntimeProtocolConformanceDescriptor>
    ) -> _TypeConformance? {
        let flags = conformanceDescriptor.pointee.conformanceFlags
        
        guard case .DirectTypeDescriptor = flags.kind else {
            return nil
        }
        
        guard let protocolDescriptorPointer = conformanceDescriptor.mutableRepresentation.pointee.protocolDescriptor else {
            return nil
        }
        
        let protocolName = String(cString: protocolDescriptorPointer.pointee.mangledName.advanced())
        
        let typeDescriptorPointer = UnsafeRawPointer(conformanceDescriptor)
            .advanced(by: MemoryLayout<SwiftRuntimeProtocolConformanceDescriptor>.offset(of: \.nominalTypeDescriptor)!)
            .advanced(by: Int(conformanceDescriptor.pointee.nominalTypeDescriptor))
        
        let descriptor = typeDescriptorPointer.assumingMemoryBound(to: SwiftRuntimeModuleContextDescriptor.self)
        
        let nominalTypeKinds = [
            SwiftRuntimeContextDescriptorFlags.Kind.class,
            SwiftRuntimeContextDescriptorFlags.Kind.struct,
            SwiftRuntimeContextDescriptorFlags.Kind.enum
        ]
        
        if descriptor.pointee.flags.isGeneric {
            return nil
        }
                
        if let name = getTypeName(descriptor: descriptor) {
            guard nominalTypeKinds.contains(where: { $0 == descriptor.pointee.flags.kind }) else {
                return nil
            }
            
            let accessFunctionPointer = UnsafeRawPointer(descriptor)
                .advanced(by: MemoryLayout<SwiftRuntimeModuleContextDescriptor>.offset(of: \.accessFunction)!)
                .advanced(by: Int(descriptor.pointee.accessFunction))
            
            let accessFunction = unsafeBitCast(accessFunctionPointer, to: (@convention(c) () -> UInt64).self)
                        
            let type: Any.Type?
            
            if descriptor.pointee.flags.isGeneric {
                type = unsafeBitCast(accessFunction(), to: Any.Type.self)
            } else {
                type = nil
            }
            
            return _TypeConformance(
                name: name,
                type: type,
                protocol: protocolName
            )
        }
        
        return nil
    }
    
    private static func getTypeName(
        descriptor: UnsafePointer<SwiftRuntimeModuleContextDescriptor>
    ) -> String? {
        let flags = descriptor.pointee.flags
        var parentName: String? = nil
        
        switch flags.kind {
            case .module, .enum, .struct, .class:
                let name = UnsafeRawPointer(descriptor)
                    .advanced(by: MemoryLayout<SwiftRuntimeModuleContextDescriptor>.offset(of: \.name)!)
                    .advanced(by: Int(descriptor.pointee.name))
                    .assumingMemoryBound(to: CChar.self)
                
                let typeName = String(cString: name)
                
                if descriptor.pointee.parent != 0 {
                    let parent = UnsafeRawPointer(descriptor)
                        .advanced(by: MemoryLayout<SwiftRuntimeModuleContextDescriptor>.offset(of: \.parent)!)
                        .advanced(by: Int(descriptor.pointee.parent))
                    
                    if abs(descriptor.pointee.parent) % 2 == 1 {
                        return nil
                    }
                    
                    parentName = getTypeName(
                        descriptor: parent.assumingMemoryBound(to: SwiftRuntimeModuleContextDescriptor.self)
                    )
                }
                
                if let parentName = parentName {
                    return "\(parentName).\(typeName)"
                }
                
                return typeName
            default:
                return nil
        }
    }
}
