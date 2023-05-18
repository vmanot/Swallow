//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Calendar: Initiable {
    public init() {
        self = .current
    }
}

extension CharacterSet: Initiable {
    
}

extension Data: Initiable {
    
}

extension Data.ReadingOptions: Initiable {
    
}

extension Data.WritingOptions: Initiable {
    
}

extension Date: Initiable {
    
}

extension DateInterval: Initiable {
    
}

extension Decimal: Initiable {
    
}

extension Locale: Initiable {
    public init() {
        self = .current
    }
}

extension NSObject: Initiable {
    
}

extension NSRegularExpression.Options: Initiable {
    public init() {
        self = .anchorsMatchLines
    }
}

extension PersonNameComponents: Initiable {
    
}

extension UUID: Initiable {
    
}
