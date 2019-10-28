//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension ProcessInfo {
    public var isTestEnvironment: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
