//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public struct Observable<T> {
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
