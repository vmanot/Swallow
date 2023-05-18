//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public protocol POSIXSynchronizationPrimitive {
    associatedtype ConstructionParameters = Void

    mutating func construct(with parameters: ConstructionParameters) throws
    mutating func construct() throws

    associatedtype DestructionParameters = Void

    mutating func destruct(with parameters: DestructionParameters) throws
    mutating func destruct() throws
}

// MARK: - Implementation

extension POSIXSynchronizationPrimitive where ConstructionParameters == Void {
    mutating public func construct(with parameters: Void) throws {
        return try construct()
    }
}

extension POSIXSynchronizationPrimitive where DestructionParameters == Void {
    mutating public func destruct(with parameters: Void) throws {
        return try destruct()
    }
}
