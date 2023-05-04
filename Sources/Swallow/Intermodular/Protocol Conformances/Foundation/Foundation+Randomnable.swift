//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension UUID: Randomnable {
    public static func random() -> Self {
        Self()
    }
}
