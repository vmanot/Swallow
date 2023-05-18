//
// Copyright (c) Vatsal Manot
//

import Swift

/// A text stream that writes to the standard output.
public struct StandardOutputTextStream: TextOutputStream {
    public init() {
        
    }
    
    public func write(_ output: String) {
        print(output)
    }
}
