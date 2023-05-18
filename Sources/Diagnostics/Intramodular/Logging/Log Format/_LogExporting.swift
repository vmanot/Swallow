//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _LogExporting {
    associatedtype Log: _LogFormat
    
    func exportLog() async throws -> Log
}
