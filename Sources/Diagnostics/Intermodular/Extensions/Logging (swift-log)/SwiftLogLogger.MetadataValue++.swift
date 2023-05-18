//
// Copyright (c) Vatsal Manot
//

#if canImport(Logging)
import Logging
import Swift

extension SwiftLogLogger.MetadataValue {
    public init<T>(from value: T) {
        if let value = value as? CustomStringConvertible {
            self = .stringConvertible(value)
        } else {
            self = .string(String(describing: value))
        }
    }
}
#endif
