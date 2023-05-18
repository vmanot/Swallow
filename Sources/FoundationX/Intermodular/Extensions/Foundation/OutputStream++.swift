//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension OutputStream {
    public var dataWrittenToMemoryStream: Data? {
        property(forKey: .dataWrittenToMemoryStreamKey) as? Data
    }
}
