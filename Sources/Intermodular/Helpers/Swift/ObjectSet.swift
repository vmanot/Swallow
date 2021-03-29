//
// Copyright (c) Vatsal Manot
//

import Swift

public struct ObjectSet<ObjectWrapper: Wrapper> where ObjectWrapper.Value: AnyObject {
    public typealias Object = ObjectWrapper.Value

    private var storage: Set<ObjectWrapperForwarder> = []

    public init() {
        
    }
}

extension ObjectSet {
    private struct ObjectWrapperForwarder: Hashable {
        var valueWrapper: ObjectWrapper

        var value: Object {
            return valueWrapper.value
        }

        init(_ value: Object) {
            self.valueWrapper = .init(value)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(value))
        }
    }
}

// MARK: - Conformances -

extension ObjectSet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
    }
}

extension ObjectSet: Sequence {
    public func makeIterator() -> AnyIterator<Object> {
        return .init(storage.lazy.map { $0.value }.makeIterator())
    }
}

extension ObjectSet: SetProtocol {
    public func contains(_ object: Object) -> Bool {
        return storage.contains(.init(object))
    }

    public func isSubset(of set: ObjectSet) -> Bool {
        return storage.isSuperset(of: set.storage)
    }

    public func isSuperset(of set: ObjectSet) -> Bool {
        return storage.isSuperset(of: set.storage)
    }

    @discardableResult
    public mutating func insert(_ object: Object) -> (inserted: Bool, Object) {
        let _result = storage.insert(.init(object))
        return (_result.inserted, _result.memberAfterInsert.value)
    }

    @discardableResult
    public mutating func remove(_ object: Object) -> Object? {
        return storage.remove(.init(object))?.value
    }
}
