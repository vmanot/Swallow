//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public class ExecuteClosureOnDeinit: ObjCObject {
    private var closure: (() -> ())?

    public init(closure: @escaping () -> ()) {
        self.closure = closure
    }

    public func dispose() {
        closure?()
        closure = nil
    }

    public func cancel() {
        closure = nil
    }
    
    deinit {
        dispose()
    }
}
