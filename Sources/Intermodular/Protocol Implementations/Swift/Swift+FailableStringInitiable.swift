//
// Copyright (c) Vatsal Manot
//

import Swift

extension Character: FailableStringInitiable {
    public init?(stringValue: String) {
        guard stringValue.count == 1 else {
            return nil
        }
        
        self.init(stringValue)
    }
}

extension String: StringInitiable {
    public init(stringValue: String) {
        self = stringValue
    }
}

extension UnicodeScalar: FailableStringInitiable {
    public init?(stringValue: String) {
        self.init(stringValue)
    }
}
