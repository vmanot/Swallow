//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)

import AppKit
import Foundation

@available(macCatalyst, unavailable)
extension NSRunningApplication {
    public convenience init(
        runningAppWithID bundleID: Bundle.ID
    ) throws {
        let app = try NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleID.rawValue }).unwrap()
        
        self.init(processIdentifier: app.processIdentifier)!
    }
}

#endif
