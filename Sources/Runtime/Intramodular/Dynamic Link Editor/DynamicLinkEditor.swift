//
// Copyright (c) Vatsal Manot
//

import Swift

/// A namespace for the dynamic link editor (aka `dyld`).
public enum DynamicLinkEditor {
}

extension DynamicLinkEditor {
    /// The address of a symbol in the current process.
    @frozen
    public struct SymbolAddress: RawRepresentable, Hashable, @unchecked Sendable {
        public let rawValue: UnsafeRawPointer

        public init(rawValue: UnsafeRawPointer) {
            self.rawValue = rawValue
        }

        public func unsafeBitCast<Value>(to type: Value.Type) -> Value {
            Swift.unsafeBitCast(rawValue, to: type)
        }
    }
}
