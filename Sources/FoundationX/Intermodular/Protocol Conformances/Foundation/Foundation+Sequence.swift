//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSAttributedString: Swift.Sequence {
    public typealias Iterator = AnyIterator<Character>
    
    public func makeIterator() -> Iterator {
        return .init(string.makeIterator())
    }
}

extension NSHashTable: Swift.Sequence {
    public typealias Iterator = NSEnumerator
    
    @objc public dynamic func makeIterator() -> Iterator {
        return objectEnumerator()
    }
}

extension NSRange: Swift.Sequence {
    public typealias Iterator = AnyIterator<Int>
    
    public func makeIterator() -> Iterator {
        return .init(((location..<(location + length)) as CountableRange).makeIterator())
    }
}

extension NSString: Swift.Sequence {
    public typealias Iterator = AnyIterator<Character>
    
    public func makeIterator() -> Iterator {
        return .init((self as String).makeIterator())
    }
}
