//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSString {
    public convenience init?(bytes: UnsafeRawPointer, length: Int, encoding: String.Encoding) {
        self.init(bytes: bytes, length: length, encoding: encoding.rawValue)
    }
    
    public convenience init?(bytes: UnsafeRawBufferPointer, length: Int, encoding: String.Encoding) {
        guard let baseAddress = bytes.baseAddress else {
            return nil
        }
        
        self.init(bytes: baseAddress, length: length, encoding: encoding.rawValue)
    }
}
