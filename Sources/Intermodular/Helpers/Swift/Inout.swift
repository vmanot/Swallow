//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public struct Inout<T> {
    public let getter: NonMutatingGetter<Void, T>
    public let setter: NonMutatingSetter<Void, T>
    
    public var wrappedValue: T {
        get {
            return getter.call(with: ())
        } nonmutating set {
            setter.call(with: ((), newValue))
        }
    }
    
    public init(getter: NonMutatingGetter<Void, T>, setter: NonMutatingSetter<Void, T>) {
        self.getter = getter
        self.setter = setter
    }
    
    public init(getter: @escaping () -> T, setter: @escaping (T) -> Void) {
        self.init(getter: .init(getter), setter: .init({ setter($1) }))
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
