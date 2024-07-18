//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Calendar: Swallow.Initiable {
    public init() {
        self = .current
    }
}

extension CharacterSet: Swallow.Initiable {
    
}

extension Data: Swallow.Initiable {
    
}

extension Data.ReadingOptions: Swallow.Initiable {
    
}

extension Data.WritingOptions: Swallow.Initiable {
    
}

extension Date: Swallow.Initiable {
    
}

extension DateInterval: Swallow.Initiable {
    
}

extension Decimal: Swallow.Initiable {
    
}

extension Locale: Swallow.Initiable {
    public init() {
        self = .current
    }
}

extension NSObject: Swallow.Initiable {
    
}

extension NSRegularExpression.Options: Swallow.Initiable {
    public init() {
        self = .anchorsMatchLines
    }
}

extension PersonNameComponents: Swallow.Initiable {
    
}

extension UUID: Swallow.Initiable {
    
}
