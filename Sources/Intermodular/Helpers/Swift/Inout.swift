//
// Copyright (c) Vatsal Manot
//

import Swift

public final class Inout<T> {
    public let getter: NonMutatingGetter<Void, T>
    public let setter: NonMutatingSetter<Void, T>
    
    public var value: T {
        get {
            return getter.call(with: ())
        } set {
            setter.call(with: ((), newValue))
        }
    }
    
    public init(getter: NonMutatingGetter<Void, T>, setter: NonMutatingSetter<Void, T>) {
        self.getter = getter
        self.setter = setter
    }
    
    public convenience init(getter: @escaping () -> T, setter: @escaping (T) -> Void) {
        self.init(getter: .init(getter), setter: .init({ setter($1) }))
    }
    
    public convenience init(_ getter: @autoclosure @escaping () -> T, _ setter: @escaping (T) -> Void) {
        self.init(getter: getter, setter: setter)
    }
}

// MARK: - Conformances -

extension Inout: CustomStringConvertible {
    public var description: String {
        return describe(value)
    }
}
