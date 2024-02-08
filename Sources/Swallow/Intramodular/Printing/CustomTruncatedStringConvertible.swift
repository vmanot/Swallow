//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol CustomTruncatedStringConvertible {
    var truncatedDescription: String { get }
}

// MARK: - Supplementary

extension String {
    @_spi(Internal)
    public init<T>(_describingTruncated x: T) {
        if let x = x as? CustomTruncatedStringConvertible {
            self = x.truncatedDescription
        } else {
            self = String(describing: x)
        }
    }
}

// MARK: - Implemented Conformances

extension UUID: CustomTruncatedStringConvertible {
    public var truncatedDescription: String {
        let string = uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        
        return "\(string.prefix(4))...\(string.suffix(4))"
    }
}

/// Writes a terse textual representation of the given item into the standard output.
public func tersePrint<T>(_ x: T) {
    if let x = x as? CustomTruncatedStringConvertible {
        Swift.print(x.truncatedDescription)
    } else {
        Swift.print(x)
    }
}
