//
// Copyright (c) Vatsal Manot
//

import Swift

public enum ObjectOwnershipQualfier {
    case autoreleasing
    case strong
    case unsafeUnretained
    case weak
}

/// A strongly typed object reference.
@propertyWrapper
public final class ObjectReference<Wrapped: AnyObject> {
    private let ownership: ObjectOwnershipQualfier
    private var base: Unmanaged<Wrapped>
    
    public var wrappedValue: Wrapped {
        get {
            base.value
        } set {
            base.value = newValue
        }
    }
    
    public init(wrappedValue: Wrapped, _ ownership: ObjectOwnershipQualfier) {
        self.ownership = ownership
        self.base = Unmanaged.pass(wrappedValue, ownership: ownership)
    }
    
    deinit {
        base.relinquish(ownership: ownership)
    }
}

/// A strongly typed object reference.
@propertyWrapper
public final class OptionalObjectReference<Wrapped: AnyObject> {
    private let ownership: ObjectOwnershipQualfier
    private var base: Unmanaged<Wrapped>?
    
    public var wrappedValue: Wrapped? {
        get {
            base?.value
        } set {
            if let newValue = newValue {
                base?.value = newValue
            } else {
                base = nil
            }
        }
    }
    
    public init(wrappedValue: Wrapped?, _ ownership: ObjectOwnershipQualfier) {
        self.ownership = ownership
        
        if let wrappedValue = wrappedValue {
            self.base = Unmanaged.pass(wrappedValue, ownership: ownership)
        }
    }
    
    deinit {
        base?.relinquish(ownership: ownership)
    }
}
