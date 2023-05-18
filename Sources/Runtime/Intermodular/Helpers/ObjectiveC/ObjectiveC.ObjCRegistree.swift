//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ObjCRegistree {
    func register()
}

public protocol ObjCDisposableRegistree: ObjCRegistree {
    func dispose()
}
