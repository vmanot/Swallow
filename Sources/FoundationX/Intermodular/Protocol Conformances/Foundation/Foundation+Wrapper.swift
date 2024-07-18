//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Foundation
import Swallow

extension CharacterSet: Swallow.Wrapper {
    public typealias Value = Set<Character>
    
    @inlinable
    public var value: Value {
        var result: Value = []
        
        for plane in (0 as UInt32)...(16 as UInt32) where hasMember(inPlane: .init(plane)) {
            var rawValue = plane << 16
            
            while rawValue < plane.successor() << 16 {
                rawValue += 1
                
                if UnicodeScalar(rawValue).map(contains) ?? false {
                    rawValue.littleEndianView.withUnsafeBytes { bytes in
                        let string = NSString(
                            bytes: bytes,
                            length: 4,
                            encoding: .utf32LittleEndian
                        )
                        
                        result += .init(string! as String)
                    }
                }
            }
        }
        
        return result
    }
    
    public init(_ value: Value) {
        self.init(charactersIn: .init(value))
    }
}
