//
// Copyright (c) Vatsal Manot
//

import Foundation

extension CanonicalFileDirectory {
    public static func sandboxed(_ name: DirectoryName) -> Self {
        self.init(_name: name, _unsandboxed: false)
    }
    
    public static func sandboxed(_ name: _UserHomeDirectoryName) -> Self {
        self.init(_name: .userHomeDirectory(name), _unsandboxed: false)
    }

    public static func unsandboxed(_ name: DirectoryName) -> Self {
        self.init(_name: name, _unsandboxed: true)
    }
    
    public static func unsandboxed(_ name: _UserHomeDirectoryName) -> Self {
        self.init(_name: .userHomeDirectory(name), _unsandboxed: true)
    }
}

extension CanonicalFileDirectory {
    public static var desktop: Self {
        Self(_name: .userHomeDirectory(.desktop))
    }
    
    public static var downloads: Self {
        Self(_name: .userHomeDirectory(.downloads))
    }
    
    public static var documents: Self {
        Self(_name: .userHomeDirectory(.documents))
    }
    
    public static var applicationSupportFiles: Self {
        Self(_name: .applicationSupportFiles)
    }
    
    public static func iCloudDriveDocuments(containerID: String) -> Self {
        Self(_name: .iCloudDriveDocuments(containerID: containerID))
    }
    
    public static func securityApplicationGroup(_ id: String) -> Self {
        Self(_name: .securityApplicationGroup(id))
    }
    
    public static func ubiquityContainer(_ id: String) -> Self {
        Self(_name: .ubiquityContainer(id))
    }
    
    public static var appResources: Self {
        Self(_name: .appResources)
    }
    
    public static var appDocuments: Self {
        Self(_name: .appDocuments)
    }
    
    public static var userDocuments: Self {
        Self(_name: .appDocuments) // FIXME: How does this differ from `appDocuments`?
    }
    
    public static var xcodeDerivedData: Self {
        Self(_name: .xcodeDerivedData)
    }
}
