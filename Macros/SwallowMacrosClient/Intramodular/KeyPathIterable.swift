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

public extension KeyPathIterable {
    static var allAnyKeyPaths: [AnyKeyPath] {
        allKeyPaths.map { $0 as AnyKeyPath }
    }
    
    var allKeyPaths: [PartialKeyPath<Self>] {
        Self.allKeyPaths
    }
    
    var allAnyKeyPaths: [AnyKeyPath] {
        allKeyPaths.map { $0 as AnyKeyPath }
    }
    
    var recursivelyAllKeyPaths: [PartialKeyPath<Self>] {
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
    
    var recursivelyAllAnyKeyPaths: [AnyKeyPath] {
        recursivelyAllKeyPaths.map { $0 as AnyKeyPath }
    }
    
    static var additionalKeyPaths: [PartialKeyPath<Self>] {
        []
    }
}
