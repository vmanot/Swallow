//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension ProcessInfo {
    public var _isRunningWithinContinuousIntegrationEnvironment: Bool {
        environment["CI"] != nil // FIXME: (@tahabebek) this needs to be something distinct like PRETERNATURAL_CI_CD
    }
    
    public var _isRunningWithinXCTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
