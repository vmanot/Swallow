//
// Copyright (c) Vatsal Manot
//


import Foundation
import MachO

public extension segment_command_64 {
    var name: String {
        String(
            tuple16: segname
        )
    }
}

public extension segment_command {
    var name: String {
        String(
            tuple16: segname
        )
    }
}

public extension section_64 {
    var name: String {
        String(
            tuple16: sectname
        )
    }
}

public extension section {
    var name: String {
        String(
            tuple16: sectname
        )
    }
}

public extension String {
    typealias Tuple16 = (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)
    
    init(
        tuple16: Tuple16
    ) {
        let count = 16
        var table = [Int8](repeating: 0, count: count + 1)
        withUnsafePointer(to: tuple16) { ptr in
            ptr.withMemoryRebound(to: Int8.self, capacity: count) { ptr in
                for i in 0..<count {
                    table[i] = ptr[i]
                }
            }
        }
        self.init(cString: table)
    }
    
    init(
        data: Data,
        offset: Int,
        commandSize: Int,
        loadCommandString: lc_str
    ) {
        let loadCommandStringOffset = Int(loadCommandString.offset)
        let stringOffset = offset + loadCommandStringOffset
        let length = commandSize - loadCommandStringOffset
        self = String(data: data[stringOffset..<(stringOffset + length)], encoding: .utf8)?
            .trimmingCharacters(in: .controlCharacters)
        ?? ""
    }
    
    init(
        loadCommandPointer: UnsafeRawPointer,
        commandSize: Int,
        loadCommandString: lc_str
    ) {
        let loadCommandStringOffset = Int(loadCommandString.offset)
        let stringPointer = loadCommandPointer.advanced(by: loadCommandStringOffset)
        let count = commandSize - loadCommandStringOffset
        let data = Data(bytes: stringPointer, count: count)
        self = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .controlCharacters)
        ?? ""
    }
}
