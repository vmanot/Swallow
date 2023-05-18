//
// Copyright (c) Vatsal Manot
//

import Foundation
import FoundationX
import Swallow

#if os(macOS)
extension NSAffineTransform: ObjectiveCBridgee {
    public typealias SwiftType = AffineTransform
}
#endif

extension NSCalendar: ObjectiveCBridgee {
    public typealias SwiftType = Calendar
}

extension NSCharacterSet: ObjectiveCBridgee {
    public typealias SwiftType = CharacterSet
}

extension NSData: ObjectiveCBridgee {
    public typealias SwiftType = Data
}

extension NSDate: ObjectiveCBridgee {
    public typealias SwiftType = Date
}

extension NSDateComponents: ObjectiveCBridgee {
    public typealias SwiftType = DateComponents
}

extension NSDateInterval: ObjectiveCBridgee {
    public typealias SwiftType = DateInterval
}

extension NSIndexPath: ObjectiveCBridgee {
    public typealias SwiftType = IndexPath
}

extension NSIndexSet: ObjectiveCBridgee {
    public typealias SwiftType = IndexSet
}

extension NSLocale: ObjectiveCBridgee {
    public typealias SwiftType = Locale
}

extension NSString: ObjectiveCBridgee {
    public typealias SwiftType = String
}

extension NSURL: ObjectiveCBridgee {
    public typealias SwiftType = URL
}

extension NSURLComponents: ObjectiveCBridgee {
    public typealias SwiftType = URLComponents
}
