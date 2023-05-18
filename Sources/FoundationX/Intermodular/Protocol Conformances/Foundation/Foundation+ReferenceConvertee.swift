//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

#if os(macOS)

extension NSAffineTransform: ReferenceConvertee {
    public typealias ReferenceConvertibleType = AffineTransform
}

#endif

extension NSCalendar: ReferenceConvertee {
    public typealias ReferenceConvertibleType = Calendar
}

extension NSCharacterSet: ReferenceConvertee {
    public typealias ReferenceConvertibleType = CharacterSet
}

extension NSData: ReferenceConvertee {
    public typealias ReferenceConvertibleType = Data
}

extension NSDate: ReferenceConvertee {
    public typealias ReferenceConvertibleType = Date
}

extension NSDateComponents: ReferenceConvertee {
    public typealias ReferenceConvertibleType = DateComponents
}

extension NSDateInterval: ReferenceConvertee {
    public typealias ReferenceConvertibleType = DateInterval
}

extension NSIndexPath: ReferenceConvertee {
    public typealias ReferenceConvertibleType = IndexPath
}

extension NSIndexSet: ReferenceConvertee {
    public typealias ReferenceConvertibleType = IndexSet
}

extension NSLocale: ReferenceConvertee {
    public typealias ReferenceConvertibleType = Locale
}

extension NSURL: ReferenceConvertee {
    public typealias ReferenceConvertibleType = URL
}

extension NSURLComponents: ReferenceConvertee {
    public typealias ReferenceConvertibleType = URLComponents
}
