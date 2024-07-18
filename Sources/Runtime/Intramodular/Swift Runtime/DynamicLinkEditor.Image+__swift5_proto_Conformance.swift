//
// Copyright (c) Vatsal Manot
//

import MachO
import Foundation
import Swallow

extension DynamicLinkEditor.Image {
    func _parseSwiftProtocolConformances() -> [__swift5_proto_Conformance] {
        guard let header = UnsafeRawPointer(self.header) else {
            return []
        }
        
        var size: UInt = 0
        let section = header.withMemoryRebound(to: mach_header_64.self, capacity: 1) { pointer in
            getsectiondata(unsafeBitCast(pointer), "__TEXT", "__swift5_proto", &size)
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
    
    public func _parseSwiftProtocolConformancesPerType1() -> [_swift_TypeConformanceList] {
        var result = [TypeMetadata: _swift_TypeConformanceList]()
        
        var sectionSize: UInt = 0
        let rawHeaderPointer = UnsafeRawPointer(self.header)
        
        let sectionStart = UnsafeRawPointer(
            getsectiondata(
                rawHeaderPointer.assumingMemoryBound(to: _inferredType()),
                "__TEXT",
                "__swift5_proto",
                &sectionSize
            )
        )
        
        guard var sectionData = sectionStart?.assumingMemoryBound(to: Int32.self) else {
            return []
        }
        
        for _ in 0..<(Int(sectionSize) / MemoryLayout<Int32>.size) {
            let conformance: UnsafeMutablePointer<SwiftRuntimeProtocolConformanceDescriptor> = UnsafeMutableRawPointer(mutating: sectionData)
                .advanced(by: Int(sectionData.pointee))
                .assumingMemoryBound(to: SwiftRuntimeProtocolConformanceDescriptor.self)
            
            if let conformance = Self._parseConformance(from: conformance) {
                if let type = conformance.type {
                    result[type, default: .init(type: type, conformances: .init())].conformances.append(conformance)
                }
            }
            
            sectionData = sectionData.successor()
        }
        
        return result
            .filter({ !$0.value.isEmpty })
            .map { (key: TypeMetadata, value: _swift_TypeConformanceList) in
                value
            }
    }
    
    public func _parseSwiftProtocolConformancesPerType2() -> [_swift_TypeConformanceList] {
        let conformances = _parseSwiftProtocolConformances()
        
        var result: [TypeMetadata: IdentifierIndexingArrayOf<_swift_TypeConformanceList.Conformance>] = [:]
        
        for conformance in conformances {
            guard let contextDescriptor = conformance.contextDescriptor, !contextDescriptor.flags.isGeneric else {
                continue
            }
            
            guard conformance.kind != nil else {
                continue
            }
            
            guard let type = contextDescriptor.metadata().map({ TypeMetadata($0) }) ?? conformance.type.map({ TypeMetadata($0) }) else {
                continue
            }
            
            guard let protocolContext: _swift_GenericContext = conformance.protocol else {
                continue
            }
            
            let protocolType: TypeMetadata? = protocolContext.metadata().map({ TypeMetadata($0) })
            
            result[type, default: []].append(
                _swift_TypeConformanceList.Conformance(
                    conformance: conformance,
                    type: type,
                    typeName: nil,
                    protocolType: protocolType,
                    protocolName: nil
                )
            )
        }
        
        return result.map { key, value in
            _swift_TypeConformanceList(type: key, conformances: value)
        }
    }
    
    private static func _parseConformance(
        from conformanceDescriptor: UnsafePointer<SwiftRuntimeProtocolConformanceDescriptor>
    ) -> _swift_TypeConformanceList.Conformance? {
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
        
        return _swift_TypeConformanceList.Conformance(
            conformance: nil,
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
                let name: UnsafePointer<CChar> = UnsafeRawPointer(descriptor)
                    .advanced(by: MemoryLayout<SwiftRuntimeModuleContextDescriptor>.offset(of: \.name)!)
                    .advanced(by: Int(descriptor.pointee.name))
                    .assumingMemoryBound(to: CChar.self)
                
                guard descriptor.pointee.accessFunction != 0 else {
                    return nil
                }
                
                let typeName = String(cString: name)
                
                guard !typeName.hasProblematicCharacters else {
                    return nil
                }
                
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

// MARK: - Internal

extension String {
    fileprivate var hasProblematicCharacters: Bool {
        let problematicCharacters = CharacterSet(charactersIn: "\u{FFFD}\u{0000}-\u{001F}\u{007F}-\u{009F}�")
        
        return self.rangeOfCharacter(from: problematicCharacters) != nil
    }
}
