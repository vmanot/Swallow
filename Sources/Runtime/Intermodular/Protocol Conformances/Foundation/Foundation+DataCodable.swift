//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Data: DataCodableWithDefaultStrategies {
    public init(data: Data, using _: Void) throws {
        self = data
    }
    
    public func data(using _: Void) throws -> Data {
        return self
    }
}

extension NSData: DataEncodableWithDefaultStrategy {
    public typealias DataEncodingStrategy = Data.DataEncodingStrategy
}

extension NSString: DataEncodableWithDefaultStrategy {
    public typealias DataEncodingStrategy = String.DataEncodingStrategy
}

extension NSValue: DataEncodableWithDefaultStrategy {
    public func data(using _: Void) throws -> Data {
        var data = try Data(repeating: 0, count: objCTypeEncoding.sizeInBytes)
        
        data.withUnsafeMutableBytes {
            getValue($0.baseAddress!)
        }
        
        return data
    }
}
