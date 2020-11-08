//
// Copyright (c) Vatsal Manot
//

import Swift

extension UnicodeScalar {
    @inlinable
    public init?(exactly rawValue: UInt32) {
        guard rawValue <= UInt32(UInt16.max) && !(55296..<57344).contains(rawValue) else {
            return nil
        }
        
        self.init(rawValue)
    }
}
