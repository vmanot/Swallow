//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCAssociationKey<Value> {
    class _Storage: ReferenceBox<ObjCAssociationPolicy> {
        deinit {
            assertionFailure()
        }
    }
    
    private let storage: _Storage
    
    public var policy: ObjCAssociationPolicy {
        return storage.value
    }
    
    public init(
        policy: ObjCAssociationPolicy = .retain,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.storage = _memoize(uniquingWith: (policy, file.description, line)) {
            _Storage(policy)
        }
    }
}

// MARK: - Conformances

extension ObjCAssociationKey: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage === rhs.storage
    }
}

extension ObjCAssociationKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(storage))
    }
}

extension ObjCAssociationKey: RawValueConvertible {
    public typealias RawValue = UnsafeRawPointer
    
    public var rawValue: RawValue {
        unsafeBitCast(storage, to: UnsafeRawPointer.self)
    }
}
