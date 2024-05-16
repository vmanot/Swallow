//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct _DJB2PersistentHasher {
    public typealias HashType = Int
    
    private struct State: Encodable, @unchecked Sendable {
        public var data: String = ""
    }
    
    private var state = State()
    
    public init() {
        
    }
    
    public mutating func combine<H: Codable>(_ value: H) throws {
        if let value = value as? String {
            state.data.append(value)
        } else {
            let encoder = JSONEncoder()
            
            encoder.outputFormatting = [.sortedKeys]
            
            let encoded = try String(data: encoder.encode(value), using: .init(encoding: .utf8))
            
            state.data.append(encoded)
        }
    }
    
    public func finalize() throws -> Int {
        state.data._djb2_persistentHash
    }
}

// MARK: - Internal

extension String {
    fileprivate var _djb2_persistentHash: Int {
        self.utf8.reduce(into: 5381) { (result: inout Int, element) -> Void in
            var newResult: Int = (result << 5)
            
            newResult &+= result
            newResult &+= Int(element)
            
            result = newResult
        }
    }
}
