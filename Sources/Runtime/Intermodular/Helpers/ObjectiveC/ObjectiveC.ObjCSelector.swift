//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCSelector: Trivial {
    public let value: Selector

    public init(_ value: Selector) {
        self.value = value
    }
}

// MARK: - Conformances

extension ObjCSelector: CustomStringConvertible {
    public var description: String {
        return value.description
    }
}

extension ObjCSelector: Equatable {
    public static func == (lhs: ObjCSelector, rhs: ObjCSelector) -> Bool {
        return lhs.value == rhs.value
    }
}

extension ObjCSelector: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Selector.StringLiteralType

    public init(stringLiteral value: StringLiteralType) {
        self.init(.init(stringLiteral: value))
    }
}

extension ObjCSelector: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension ObjCSelector: ObjCCodable {
    public var objCTypeEncoding: ObjCTypeEncoding {
        return Selector.objCTypeEncoding
    }
}

extension ObjCSelector: ObjCRegistree {
    public func register() {
        sel_registerName(value.value)
    }
}

extension ObjCSelector: Named, NameInitiable {
    public var name: String {
        return value.stringValue
    }

    public init(name: String) {
        self.init(stringLiteral: name)
    }
}

extension ObjCSelector: RawRepresentable {
    public var rawValue: String {
        return value.value
    }
    
    public init(rawValue: String) {
        self.init(Selector(rawValue))
    }
}

// MARK: - Auxiliary Extensions

extension ObjCSelector {
    static let forwardInvocation: ObjCSelector = "forwardInvocation:"
    static let preserved_forwardInvocation: ObjCSelector = "preserved_forwardInvocation:"
}

// MARK: - Helpers

extension DictionaryProtocol where DictionaryKey == ObjCSelector {
    public subscript(_ key: Selector) -> DictionaryValue? {
        return self[.init(key)]
    }
}
