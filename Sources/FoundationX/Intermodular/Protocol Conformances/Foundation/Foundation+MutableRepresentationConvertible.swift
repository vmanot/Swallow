//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSAttributedString: MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableAttributedString {
        return .init(attributedString: self)
    }
}

extension NSCharacterSet: MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableCharacterSet {
        return mutableCopy() as! NSMutableCharacterSet
    }
}

extension NSDictionary: MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableDictionary {
        return .init(dictionary: self)
    }
}

extension NSData: MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableData {
        return NSMutableData(data: self as Data)
    }
}

extension NSSet: MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableSet {
        return .init(set: self)
    }
}

extension NSString: MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableString {
        return .init(string: self)
    }
}
