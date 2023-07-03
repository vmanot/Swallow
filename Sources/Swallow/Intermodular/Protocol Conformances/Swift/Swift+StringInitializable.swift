//
// Copyright (c) Vatsal Manot
//

import Swift

extension Character: StringInitializable {
    public init?(stringValue: String) {
        guard stringValue.count == 1 else {
            return nil
        }
        
        self.init(stringValue)
    }
}

extension String: StringInitializable {
    public init(stringValue: String) {
        self = stringValue
    }
}

extension UnicodeScalar: StringInitializable {
    public init?(stringValue: String) {
        self.init(stringValue)
    }
}
