//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(extension, conformances: KeyPathIterable, names: arbitrary)
public macro KeyPathIterable() = #externalMacro(
    module: "SwallowMacros",
    type: "KeyPathIterableMacro"
)

public protocol KeyPathIterable {
    static var allKeyPaths: [PartialKeyPath<Self>] { get }
    static var allAnyKeyPaths: [AnyKeyPath] { get }
    static var additionalKeyPaths: [PartialKeyPath<Self>] { get }
    
    var allKeyPaths: [PartialKeyPath<Self>] { get }
    var allAnyKeyPaths: [AnyKeyPath] { get }
    
    var recursivelyAllKeyPaths: [PartialKeyPath<Self>] { get }
    var recursivelyAllAnyKeyPaths: [AnyKeyPath] { get }
}

extension KeyPathIterable {
    public static var allAnyKeyPaths: [AnyKeyPath] {
        allKeyPaths.map { $0 as AnyKeyPath }
    }
    
    public var allKeyPaths: [PartialKeyPath<Self>] {
        Self.allKeyPaths
    }
    
    public var allAnyKeyPaths: [AnyKeyPath] {
        allKeyPaths.map { $0 as AnyKeyPath }
    }
    
    public var recursivelyAllKeyPaths: [PartialKeyPath<Self>] {
        var recursivelyKeyPaths = [PartialKeyPath<Self>]()
        for keyPath in allKeyPaths {
            recursivelyKeyPaths.append(keyPath)
            if let anyKeyPathIterable = self[keyPath: keyPath] as? any KeyPathIterable {
                for childKeyPath in anyKeyPathIterable.recursivelyAllAnyKeyPaths {
                    if let appendedKeyPath = keyPath.appending(path: childKeyPath) {
                        recursivelyKeyPaths.append(appendedKeyPath)
                    }
                }
            }
        }
        return recursivelyKeyPaths
    }
    
    public var recursivelyAllAnyKeyPaths: [AnyKeyPath] {
        recursivelyAllKeyPaths.map { $0 as AnyKeyPath }
    }
    
    public static var additionalKeyPaths: [PartialKeyPath<Self>] {
        []
    }
}

// MARK: - Supplementary

#if canImport(Observation)
import Observation

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
extension Observable {
    public func _accessAllKeyPathsIfTypeIsKeyPathIterable() {
        guard let keyPaths: [AnyKeyPath] = (self as? (any KeyPathIterable)).map({ type(of: $0).allAnyKeyPaths }) else {
            return
        }
        
        for keyPath in keyPaths {
            _ = _takeOpaqueExistentialUnoptimized(self[keyPath: keyPath] as Any)
        }
    }
}
#endif
