//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol ReferenceValueConvertible {
    associatedtype ReferenceValue: NSObject
    
    var referenceValue: ReferenceValue { get }
}

public protocol MutableReferenceValueConvertible: ReferenceValueConvertible {
    var mutableReferenceValue: ReferenceValue { mutating get mutating set }
}
