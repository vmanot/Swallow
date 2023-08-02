//
// Copyright (c) Vatsal Manot
//

import Swift

protocol _PlaceholderInitiable {
    init()
}

// MARK: - Implemented Conformances

extension Array: _PlaceholderInitiable {
    
}

extension Bool: _PlaceholderInitiable {
    
}

extension Character: _PlaceholderInitiable {
    public init() {
        self.init(" ")
    }
}

extension Dictionary: _PlaceholderInitiable {
    
}

extension Double: _PlaceholderInitiable {
    
}

extension Float: _PlaceholderInitiable {
    
}

extension Int: _PlaceholderInitiable {
    
}

extension Int8: _PlaceholderInitiable {
    
}

extension Int16: _PlaceholderInitiable {
    
}

extension Int32: _PlaceholderInitiable {
    
}

extension Int64: _PlaceholderInitiable {
    
}

extension Set: _PlaceholderInitiable {
    
}

extension String: _PlaceholderInitiable {
    
}

extension Substring: _PlaceholderInitiable {
    
}

extension UInt: _PlaceholderInitiable {
    
}

extension UInt8: _PlaceholderInitiable {
    
}

extension UInt16: _PlaceholderInitiable {
    
}

extension UInt32: _PlaceholderInitiable {
    
}

extension UInt64: _PlaceholderInitiable {
    
}

extension AsyncStream: _PlaceholderInitiable {
    public init() {
        self.init {
            $0.finish()
        }
    }
}

extension AsyncThrowingStream: _PlaceholderInitiable where Failure == Error {
    public init() {
        self.init {
            $0.finish(throwing: CancellationError())
        }
    }
}

#if canImport(Foundation)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
extension Data: _PlaceholderInitiable {
    
}

extension Date: _PlaceholderInitiable {
    
}

extension Decimal: _PlaceholderInitiable {
    
}

extension UUID: _PlaceholderInitiable {
    
}

extension URL: _PlaceholderInitiable {
    init() {
        self.init(string: "/")!
    }
}
#endif
