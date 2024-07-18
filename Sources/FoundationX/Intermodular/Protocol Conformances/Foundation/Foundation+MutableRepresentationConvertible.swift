//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSAttributedString: Swallow.MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableAttributedString {
        return .init(attributedString: self)
    }
}

extension NSCharacterSet: Swallow.MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableCharacterSet {
        return mutableCopy() as! NSMutableCharacterSet
    }
}

extension NSDictionary: Swallow.MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableDictionary {
        return .init(dictionary: self)
    }
}

extension NSData: Swallow.MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableData {
        return NSMutableData(data: self as Data)
    }
}

extension NSSet: Swallow.MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableSet {
        return .init(set: self)
    }
}

extension NSString: Swallow.MutableRepresentationConvertible {
    public var mutableRepresentation: NSMutableString {
        return .init(string: self)
    }
}
