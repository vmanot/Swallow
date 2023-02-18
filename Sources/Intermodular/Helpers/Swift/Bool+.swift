//
// Copyright (c) Vatsal Manot
//

import Swift

extension Bool {
    public struct True: _StaticBoolean {
        public static let value: Bool = true
    }
    
    public struct False: _StaticBoolean {
        public static let value: Bool = false
    }
}
