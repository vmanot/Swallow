//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public protocol _StaticValue: _StaticType {
    associatedtype Value
    
    static var value: Value { get }
}

public protocol _StaticBoolean: _StaticValue where Value == Bool {
    
}

public protocol _StaticInteger: _StaticValue where Value == Int {
    
}
