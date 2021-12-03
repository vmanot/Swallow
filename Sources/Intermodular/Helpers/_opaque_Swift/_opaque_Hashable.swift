//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_Hashable: _opaque_Equatable {
    var hashValue: Int { get }

    func hash(into hasher: inout Hasher)
    
    func toAnyHashable() -> AnyHashable
}

// MARK: - Implementation -

extension _opaque_Hashable where Self: Hashable {
    public func toAnyHashable() -> AnyHashable {
        return .init(self)
    }
}

// MARK: - Auxiliary Implementation -

@_disfavoredOverload
public func == (lhs: AnyHashable, rhs: _opaque_Hashable) -> Bool {
    lhs == rhs.toAnyHashable()
}

@_disfavoredOverload
public func == <T: Hashable>(lhs: _opaque_Hashable, rhs: T) -> Bool {
    lhs.toAnyHashable() == AnyHashable(rhs)
}

@_disfavoredOverload
public func == <T: _opaque_Hashable, U: Hashable>(lhs: T, rhs: U) -> Bool {
    lhs.toAnyHashable() == AnyHashable(rhs)
}
