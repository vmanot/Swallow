//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCMethodDescription: CustomDebugStringConvertible, CustomStringConvertible, MutableWrapper {
    public typealias Value = objc_method_description

    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public init(_ selector: Selector, _ types: String) {
        self.init(.init(name: selector, types: types.nullTerminatedUTF8String().value))
    }
}

extension ObjCMethodDescription {
    public var signature: ObjCMethodSignature {
        get {
            return .init(rawValue: String(utf8String: value.types)!)
        } set {
            value.types = newValue.rawValue.nullTerminatedUTF8String().value
        }
    }

    public var selector: ObjCSelector! {
        get {
            return value.name.map(ObjCSelector.init)
        } set {
            value.name = newValue.value
        }
    }

    var isInvalid: Bool {
        return selector == nil
    }
}

// MARK: - Conformances

extension ObjCMethodDescription: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(signature)
    }
}

extension ObjCMethodDescription: MutableNamed {
    public var name: String {
        get {
            return selector.name
        } set {
            selector = .init(name: newValue)
        }
    }
}

// MARK: - Helpers

extension AnyRandomAccessCollection where Element == ObjCMethodDescription {
    public func filterOutInvalids() -> AnyRandomAccessCollection<ObjCMethodDescription> {
        return AnyRandomAccessCollection(filter { !$0.isInvalid })
    }
}
