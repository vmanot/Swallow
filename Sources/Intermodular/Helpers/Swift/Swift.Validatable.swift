//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Validatable: AnyProtocol {
    var isValid: Bool { get }

    func validate() throws
}

extension Validatable {
    public func validate() throws {
        _ = try isValid.orThrow(EmptyError())
    }
}
