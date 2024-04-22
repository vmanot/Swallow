//
// Copyright (c) Vatsal Manot
//

import Foundation
import MachO
import SwiftUI

extension DynamicLinkEditor.Image {
    public struct LoadCommand {
        public let baseAddress: UnsafePointer<load_command>
        public let type: LoadCommandType
        public let size: Int
        
        init?(baseAddress: UnsafePointer<load_command>) {
            if Int(baseAddress.pointee.cmd) > Int(Int32.max) {
                return nil
            }
            
            self.baseAddress = baseAddress
            self.type = LoadCommandType(rawValue: Int32(baseAddress.pointee.cmd))
            self.size = Int(baseAddress.pointee.cmdsize)
        }
        
        func asSegmentCommand64() -> UnsafePointer<segment_command_64>? {
            guard type == .segment64 else {
                return nil
            }
            
            return baseAddress.assumingMemoryBound(to: segment_command_64.self)
        }
        
        func asSymtabCommand() -> UnsafePointer<symtab_command>? {
            guard type == .symtab else {
                return nil
            }
            
            return baseAddress.assumingMemoryBound(to: symtab_command.self)
        }
    }
    
    public struct LoadCommandIterator: Sequence, IteratorProtocol {
        let header: UnsafePointer<mach_header_64>
        
        private var currentOffset = 0
        
        init(header: UnsafePointer<mach_header_64>) {
            self.header = header
        }
        
        public mutating func next() -> LoadCommand? {
            guard currentOffset < Int(header.pointee.sizeofcmds) else {
                return nil
            }
            
            let loadCommandPtr = UnsafeRawPointer(header)
                .advanced(by: MemoryLayout<mach_header_64>.size + currentOffset)
                .assumingMemoryBound(to: load_command.self)
            
            currentOffset += Int(loadCommandPtr.pointee.cmdsize)
            
            let result = LoadCommand(baseAddress: loadCommandPtr)
            
            if result == nil {
                return next()
            } else {
                return result
            }
        }
    }
}
