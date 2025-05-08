//
// Copyright (c) Vatsal Manot
//

import Swift

extension _StaticSwift {
    public protocol Module {
        static var uniqueIdentifier: StaticString? { get }
    }
}

extension _StaticSwift.Module {
    public static var uniqueIdentifier: StaticString? {
        get {
            nil
        }
    }
}

extension _StaticSwift {
    public struct ModuleInfo: Codable, Hashable, Sendable {
        public let uniqueIdentifier: String?
        public let swiftTypeName: String

        public init(from type: _StaticSwift.Module.Type) {
            self.uniqueIdentifier = type.uniqueIdentifier.map({ String($0.description) })
            self.swiftTypeName = _getSanitizedTypeName(from: type, qualified: true)
        }
    }
}
