//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Warning: Error, Sendable {
    
}

public func warn(_ error: Error) {
    print(error)
}
