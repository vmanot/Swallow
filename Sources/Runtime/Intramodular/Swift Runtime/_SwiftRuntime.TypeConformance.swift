//
// Copyright (c) Vatsal Manot
//

import MachO
import Swallow

extension _SwiftRuntime {
    @frozen
    public struct TypeConformance: Hashable, Identifiable {
        public var type: TypeMetadata?
        public let typeName: String
        public let protocolName: String?
        
        public var id: AnyHashable {
            hashValue
        }
    }
    
    public struct TypeConformances: Identifiable {
        public let type: TypeMetadata
        public let conformances: IdentifierIndexingArrayOf<TypeConformance>
        
        public var id: AnyHashable {
            type
        }
    }
}

extension _SwiftRuntime {
    static func _parseSwiftTypeConformances(
        from image: DynamicLinkEditor.Image
    ) -> [TypeConformances] {
        var result = [TypeMetadata: [TypeConformance]]()
        
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
            
            if let conformance = parseConformance(from: conformance) {
                if let type = conformance.type {
                    result[type, default: []].append(conformance)
                }
            }
            
            sectData = sectData.successor()
        }
        
        return result
            .filter({ !$0.value.isEmpty })
            .map { (key, value) -> TypeConformances in
                return TypeConformances(
                    type: key,
                    conformances: IdentifierIndexingArrayOf(value.distinct())
                )
            }
    }
    
    private static func parseConformance(
        from conformanceDescriptor: UnsafePointer<SwiftRuntimeProtocolConformanceDescriptor>
    ) -> TypeConformance? {
        let flags = conformanceDescriptor.pointee.conformanceFlags
        
        guard let kind = flags.kind else {
            return nil
        }
        
        switch kind {
            case .DirectTypeDescriptor:
                break
            case .IndirectTypeDescriptor:
                return nil
            case .DirectObjCClassName:
                break
            case .IndirectObjCClass:
                return nil
        }
        
        let typeDescriptorPointer = UnsafeRawPointer(conformanceDescriptor)
            .advanced(by: MemoryLayout<SwiftRuntimeProtocolConformanceDescriptor>.offset(of: \.nominalTypeDescriptor)!)
            .advanced(by: Int(conformanceDescriptor.pointee.nominalTypeDescriptor))
        
        let descriptor = typeDescriptorPointer.assumingMemoryBound(to: SwiftRuntimeModuleContextDescriptor.self)
        
        let nominalTypeKinds = [
            SwiftRuntimeContextDescriptorFlags.Kind.class,
            SwiftRuntimeContextDescriptorFlags.Kind.struct,
            SwiftRuntimeContextDescriptorFlags.Kind.enum
        ]
        
        guard let typeName = getTypeName(descriptor: descriptor) else {
            return nil
        }
        
        let accessFunctionPointer = UnsafeRawPointer(descriptor)
            .advanced(by: MemoryLayout<SwiftRuntimeModuleContextDescriptor>.offset(of: \.accessFunction)!)
            .advanced(by: Int(descriptor.pointee.accessFunction))
        
        let accessFunction = unsafeBitCast(accessFunctionPointer, to: (@convention(c) () -> UInt64).self)
        
        let type: Any.Type?
        
        if !descriptor.pointee.flags.isGeneric {
            type = unsafeBitCast(accessFunction(), to: Any.Type.self)
        } else {
            type = nil
        }
        
        let protocolName: String? = conformanceDescriptor.mutableRepresentation.pointee.contextDescriptor.map {
            String(cString: $0.pointee.mangledName.advanced())
        }
        
        guard nominalTypeKinds.contains(where: { $0 == descriptor.pointee.flags.kind }) else {
            return nil
        }
        
        return TypeConformance(
            type: type.map({ TypeMetadata($0) }),
            typeName: typeName,
            protocolName: protocolName
        )
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
