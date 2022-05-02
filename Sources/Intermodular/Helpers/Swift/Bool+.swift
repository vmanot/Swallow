//
// Copyright (c) Vatsal Manot
//

import Swift

extension Bool {
    public struct True: StaticValue {
        public static let value: Bool = true
    }
    
    public struct False: StaticValue {
        public static let value: Bool = false
    }
}
