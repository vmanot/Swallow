//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swallow

public struct _SwiftRuntime {
    public static var _index: _SwiftRuntimeIndex = {
        let index = _SwiftRuntimeIndex()
        
        _ = index.queryIndices

        return index
    }()
    
    public static var index: _SwiftRuntimeIndex {
        _index
    }
    
    private init() {
        
    }
}
