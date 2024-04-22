//
// Copyright (c) Vatsal Manot
//

import Foundation
import MachO
import Swallow

extension DynamicLinkEditor.Image {
    struct UnsafeRawSegments: Sequence {
        let loadCommandsIterator: LoadCommandIterator
        
        init(header: UnsafePointer<mach_header_64>) {
            self.loadCommandsIterator = LoadCommandIterator(header: header)
        }
        
        func makeIterator() -> AnyIterator<UnsafePointer<segment_command_64>> {
            var loadCommands = self.loadCommandsIterator
            
            return AnyIterator {
                while let loadCommand = loadCommands.next() {
                    if loadCommand.type == .segment64 {
                        return loadCommand.baseAddress.assumingMemoryBound(to: segment_command_64.self)
                    }
                }
                return nil
            }
        }
    }
    
    public struct UnsafeRawSymbolIterator: Sequence, IteratorProtocol {
        let symbolTableCommand: UnsafePointer<symtab_command>
        let symbolStringsPtr: UnsafePointer<CChar>
        let start: UnsafePointer<nlist_64>
        let count: Int
        let slide: Int
        
        private var currentIndex = 0
        
        init?(header: UnsafePointer<mach_header_64>, slide: Int) {
            let loadCommandsIterator = LoadCommandIterator(header: header)
            let segmentsIterator = UnsafeRawSegments(header: header)
            
            guard let symbolTableCommand: UnsafePointer<symtab_command> = loadCommandsIterator.first(where: { $0.type == .symtab }).map({ $0.baseAddress.assumingMemoryBound(to: symtab_command.self) }) else {
                return nil
            }
            
            guard let linkEditorSegment: UnsafePointer<segment_command_64> = segmentsIterator.first(where: { $0.pointee.name == SEG_LINKEDIT }) else {
                return nil
            }
            
            guard let offset = UnsafeRawPointer(bitPattern: slide + Int(linkEditorSegment.pointee.vmaddr) - Int(linkEditorSegment.pointee.fileoff)) else {
                return nil
            }
            
            self.symbolTableCommand = symbolTableCommand
            self.symbolStringsPtr = offset.advanced(by: Int(symbolTableCommand.pointee.stroff)).assumingMemoryBound(to: CChar.self)
            self.start = offset.advanced(by: Int(symbolTableCommand.pointee.symoff)).assumingMemoryBound(to: nlist_64.self)
            self.count = Int(symbolTableCommand.pointee.nsyms)
            self.slide = slide
        }
        
        public mutating func next() -> UnsafeRawSymbol? {
            guard currentIndex < count else {
                return nil
            }
            
            let result: UnsafeRawSymbol? = UnsafeRawSymbol(
                nlist: start[currentIndex],
                strings: symbolStringsPtr,
                slide: slide
            )
            
            currentIndex += 1
            
            guard let result else {
                return next()
            }
            
            return result
        }
    }
        
    public enum SymbolType: UInt8, Hashable, Sendable {
        case undefined = 0x00
        case absolute = 0x02
        case definedInSection = 0x0E
        case prebound = 0x0C
        case indirect = 0x0A
        case sectionReference = 0x24
        
        public init?(rawValue: UInt8) {
            switch Int32(rawValue) & N_TYPE {
                case N_UNDF:
                    self = .undefined
                case N_ABS:
                    self = .absolute
                case N_SECT:
                    self = .definedInSection
                case N_PBUD:
                    self = .prebound
                case N_INDR:
                    self = .indirect
                default:
                    return nil
            }
        }
        
        public var isExternal: Bool {
            return (Int32(rawValue) & N_EXT) != 0
        }
        
        public var isPrivateExternal: Bool {
            return (Int32(rawValue) & N_PEXT) != 0
        }
    }

    public struct UnsafeRawSymbol: CustomDebugStringConvertible, Hashable, Sendable {
        public let name: String
        public let type: SymbolType
        public let address: DynamicLibraryLoader.SymbolAddress

        let section: UInt8
        let description: Int32
        let value: UInt64
        
        public var debugDescription: String {
            name
        }
        
        init?(
            nlist: nlist_64,
            strings: UnsafePointer<CChar>,
            slide: Int
        ) {
            guard nlist.n_sect != NO_SECT else {
                return nil
            }
            
            guard !(nlist.n_value == 0) else {
                return nil
            }
            
            self.name = String(cString: strings.advanced(by: Int(nlist.n_un.n_strx)))
             
            guard !name.isEmpty else {
                return nil
            }
            
            guard let symbolType = SymbolType(rawValue: nlist.n_type) else {
                return nil
            }
            
            guard let symbolAddress = UnsafeRawPointer(bitPattern: Int(nlist.n_value) + slide) else {
                return nil
            }

            self.type = symbolType
            self.address = .init(rawValue: symbolAddress)
            self.section = nlist.n_sect
            self.description = Int32(nlist.n_desc)
            self.value = nlist.n_value
        }
                
        public var isExternallyVisible: Bool {
            return (description & N_WEAK_REF) == 0 && (description & N_WEAK_DEF) == 0
        }
        
        public var isWeakReferenced: Bool {
            return (description & N_WEAK_REF) != 0
        }
        
        public var isWeakDefined: Bool {
            return (description & N_WEAK_DEF) != 0
        }
    }
    
    public var _rawSymbolIterator: UnsafeRawSymbolIterator? {
        UnsafeRawSymbolIterator(header: unsafeBitCast(header), slide: slide)
    }
}
