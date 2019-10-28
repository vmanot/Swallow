//
// Copyright (c) Vatsal Manot
//

import Foundation
import os
import Swift

public struct OSSystemLog: Hashable2 {
    public static var bundleIdentifier = Bundle.main.bundleIdentifier!

    public static let `default` = OSSystemLog(subsystem: bundleIdentifier, category: .default)
    public static let ui = OSSystemLog(subsystem: bundleIdentifier, category: .ui)
    public static let network = OSSystemLog(subsystem: bundleIdentifier, category: .network)
    public static let user = OSSystemLog(subsystem: bundleIdentifier, category: .user)
    public static let cache = OSSystemLog(subsystem: bundleIdentifier, category: .cache)

    public let subsystem: String?
    public let category: Category

    public init(subsystem: String? = nil, category: Category) {
        self.subsystem = subsystem
        self.category = category
    }

    public enum Category: String {
        case `default` = "Default"
        case ui = "UI"
        case network = "Network"
        case coreData = "CoreData"
        case user = "User"
        case cache = "Cache"
    }
}

extension OSSystemLog {
    func toOSLog() -> OSLog {
        return subsystem.map({ .init(subsystem: $0, category: category.rawValue) }) ?? .default
    }
}
