//
// Copyright (c) Vatsal Manot
//

import Foundation
import Darwin
import Swift

public class Glob: Sequence, IteratorProtocol {
    var pglob = glob_t()
    var index = 0
    
    public init?(pattern: String, flags: CInt = 0) {
        if glob(pattern, flags, nil, &pglob) != 0 {
            return nil
        }
    }
    
    public func next() -> URL? {
        defer { index += 1 }
        
        guard index < pglob.gl_matchc else {
            return nil
        }
        
        return pglob.gl_pathv[index].flatMap({ URL(fileURLWithPath: String(cString: $0)) })
    }
    
    deinit {
        globfree(&pglob)
    }
}
