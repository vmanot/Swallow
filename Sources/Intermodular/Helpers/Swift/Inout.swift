//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public struct Inout<T> {
    public let getter: () -> T
    public let setter: (T) -> Void
    
    public var wrappedValue: T {
        get {
            return getter()
        } nonmutating set {
            setter(newValue)
        }
    }
        
    public init(getter: @escaping () -> T, setter: @escaping (T) -> Void) {
        self.getter = getter
        self.setter = setter
    }
    
    public init(_ getter: @autoclosure @escaping () -> T, _ setter: @escaping (T) -> Void) {
        self.init(getter: getter, setter: setter)
    }
}

// MARK: - Conformances -

extension Inout: CustomStringConvertible {
    public var description: String {
        String(describing: wrappedValue)
    }
}
