//
//  FileHandleOutputStream.swift
//  Swallow
//
//  Created by Yanan Li on 2026/1/21.
//

import Foundation

public class FileHandleOutputStream: TextOutputStream {
    public let closeOnDeinit: Bool
    public let fileHandle: FileHandle
    
    public convenience init(forPath path: String) throws {
        try Data().write(to: URL(fileURLWithPath: path), options: []) /* We do not delete original file if present to keep xattrs… */
        
        guard let fh = FileHandle(forWritingAtPath: path) else {
            throw NSError(
                domain: "LocMapperCLIErrDomain",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Cannot open file at path \(path) for writing"]
            )
        }
        
        self.init(fh: fh, closeOnDeinit: true)
    }
    
    public init(
        fh: FileHandle,
        closeOnDeinit c: Bool = false
    ) {
        closeOnDeinit = c
        fileHandle = fh
    }
    
    deinit {
        if closeOnDeinit {
            fileHandle.closeFile()
        }
    }
    
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        fileHandle.write(data)
    }
}
