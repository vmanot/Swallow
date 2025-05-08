//
// Copyright (c) Vatsal Manot
//

@_exported import _SwiftRuntimeExports
private import _RuntimeC
import ObjectiveC
import Swift

public enum _module: _StaticSwift.Module {
    public static let bundleIdentifier = "com.vmanot.Swallow"
    
    public static func initialize() {
        
    }
}

// MARK: - Deprecated

@available(*, deprecated)
public typealias module = _module
