//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCAssociationKey<Value> {
    private let storage: ReferenceBox<ObjCAssociationPolicy>
    
    public var policy: ObjCAssociationPolicy {
        return storage.value
    }
    
    public init(
        policy: ObjCAssociationPolicy = .retain,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.storage = _memoize(uniquingWith: (policy, file.description, line)) {
            ReferenceBox(policy)
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
        hasher.combine(rawValue)
    }
}

extension ObjCAssociationKey: RawValueConvertible {
    public typealias RawValue = UnsafeRawPointer
    
    public var rawValue: RawValue {
        unsafeBitCast(storage, to: UnsafeRawPointer.self)
    }
}

// MARK: - Auxiliary

public struct ObjCAssociation<Object: ObjCObject, AssociatedValue> {
    private weak var object: Object?
    
    private let key: ObjCAssociationKey<AssociatedValue>
    
    public init(object: Object?, key: ObjCAssociationKey<AssociatedValue>) {
        self.object = object
        self.key = key
    }
    
    public init(object: Object?, value: AssociatedValue) {
        self.object = object
        self.key = ObjCAssociationKey<AssociatedValue>()
        
        object?[key] = value
    }
    
    public func dissociate() {
        object?[key] = nil
    }
}
