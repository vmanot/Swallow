//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension ProcessInfo {
    public var _isRunningWithinXCTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
