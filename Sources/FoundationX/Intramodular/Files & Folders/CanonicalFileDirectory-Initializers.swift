//
// Copyright (c) Vatsal Manot
//

import Foundation

extension CanonicalFileDirectory {
    public static var desktop: Self {
        Self(_name: .desktop)
    }
    
    public static var downloads: Self {
        Self(_name: .downloads)
    }
    
    public static var documents: Self {
        Self(_name: .documents)
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
}
