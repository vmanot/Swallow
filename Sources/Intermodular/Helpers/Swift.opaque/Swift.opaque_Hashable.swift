//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Hashable2 = opaque_Hashable & Hashable

public protocol opaque_Hashable: opaque_Equatable {
    var hashValue: Int { get }

    func hash(into hasher: inout Hasher)
    
    func toAnyHashable() -> AnyHashable
}

// MARK: - Implementation -

extension opaque_Hashable where Self: Hashable {
    public func toAnyHashable() -> AnyHashable {
        return .init(self)
    }
}
