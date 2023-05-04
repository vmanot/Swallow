//
// Copyright (c) Vatsal Manot
//

import Swift

extension Character: StringConvertible {
    public var stringValue: String {
        return .init(self)
    }
}

extension String: MutableStringConvertible {
    public var stringValue: String {
        get {
            return self
        } set {
            self = newValue
        }
    }
}

extension Substring: StringConvertible {
    public var stringValue: String {
        return .init(self)
    }
}

extension UnicodeScalar: StringConvertible {
    public var stringValue: String {
        return .init(self)
    }
}
