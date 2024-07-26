//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Thread {
    public static var _isMainThread: Bool {
        isMainThread
    }
}
