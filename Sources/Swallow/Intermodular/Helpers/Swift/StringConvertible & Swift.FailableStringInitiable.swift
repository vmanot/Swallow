//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol StringConvertible: Hashable {
    var stringValue: String { get }
}

public protocol MutableStringConvertible: StringConvertible {
    var stringValue: String { get set }
}

public protocol StringInitializable {
    init?(stringValue: String)
}

public typealias StringRepresentable = StringInitializable & StringConvertible
