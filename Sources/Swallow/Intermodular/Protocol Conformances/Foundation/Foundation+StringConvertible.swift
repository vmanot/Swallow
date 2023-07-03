//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension UUID: StringRepresentable {
    public var stringValue: String {
        uuidString
    }
    
    public init?(stringValue: String) {
        self.init(uuidString: stringValue)
    }
}
