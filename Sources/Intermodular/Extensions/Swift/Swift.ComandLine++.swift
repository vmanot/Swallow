//
// Copyright (c) Vatsal Manot
//

#if canImport(Cocoa)

import Swift
import Cocoa

extension CommandLine {
    public static var isRunningFromCommandLine: Bool {
        let isTTY = isatty(STDIN_FILENO)
        
        #if DEBUG
        let isRunningFromXcode = arguments.contains("-NSDocumentRevisionsDebugMode")
        #else
        let isRunningFromXcode = false
        #endif
        
        return isTTY == 1 && !isRunningFromXcode
    }
}

#endif
