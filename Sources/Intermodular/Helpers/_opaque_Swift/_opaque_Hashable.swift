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
