//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// A timestamp with a description suitable for use in filenames.
@_spi(Internal)
public struct Timestamp {
    private let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    public init() {
        self.init(date: Date())
    }
}

// MARK: - Conformances

@_spi(Internal)
extension Timestamp: CustomStringConvertible {
    public var description: String {
        String(Int(date.timeIntervalSince1970))
    }
}
