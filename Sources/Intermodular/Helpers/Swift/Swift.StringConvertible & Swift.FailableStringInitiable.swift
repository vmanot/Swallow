//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol StringConvertible {
    var stringValue: String { get }
}

public protocol MutableStringConvertible: StringConvertible {
    var stringValue: String { get set }
}

public protocol FailableStringInitiable {
    init?(stringValue: String)
}

public protocol StringInitiable: FailableStringInitiable {
    init(stringValue: String)
}

public typealias StringRepresentable = FailableStringInitiable & StringConvertible
