//
// Copyright (c) Vatsal Manot
//

internal import _RuntimeC
import ObjectiveC
import Swift

public enum _module: _StaticSwift.module {
    public static let bundleIdentifier = "com.vmanot.Swallow"
    
    public static func initialize() {
        
    }
}

// MARK: - Deprecated

@available(*, deprecated)
public typealias module = _module
