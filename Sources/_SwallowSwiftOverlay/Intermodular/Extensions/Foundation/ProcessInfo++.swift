//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension ProcessInfo {
    public var _isRunningWithinContinuousIntegrationEnvironment: Bool {
        environment["CI"] != nil
    }
    
    public var _isRunningWithinXCTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

