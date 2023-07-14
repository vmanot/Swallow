//
// Copyright (c) Vatsal Manot
//

import Swallow

@propertyWrapper
public struct _Union<T> {
    private let _underlyingValue: Any
    
    public var wrappedValue: T {
        _underlyingValue as! T
    }
    
    private init(_underlyingValue value: Any) {
        self._underlyingValue = value
    }
    
    public init(wrappedValue: T) {
        try! Self._validatePropertyWrapperType()
        
        self.init(_underlyingValue: wrappedValue)
    }
    
    public static func _validatePropertyWrapperType() throws {
        let metadata = TypeMetadata(T.self)
        
        switch metadata.typed {
            case let tuple as TypeMetadata.Tuple:
                try tuple.fields
                    .map({ $0.type.toMetatype() })
                    .enumerated()
                    .forEach { (index, element) in
                        guard (element is any OptionalProtocol.Type) else {
                            throw _StaticValidationError.nonOptionalType(element, at: index)
                        }
                    }
            default:
                break
        }
    }
    
    private enum _StaticValidationError: Error {
        case nonOptionalType(Any.Type, at: Int)
    }
}

extension _Union {
    public init<T0, T1>(_ first: T0) where T == (T0, T1) {
        self.init(_underlyingValue: (first, nil) as (T0?, T1?))
    }
    
    public init<T0, T1>(_ first: T0) where T == (T0?, T1?) {
        self.init(_underlyingValue: (first, nil) as (T0?, T1?))
    }
    
    public init<T0, T1>(_ second: T1) where T == (T0, T1) {
        self.init(_underlyingValue: (nil, second) as (T0?, T1?))
    }
    
    public init<T0, T1>(_ second: T1) where T == (T0?, T1?) {
        self.init(_underlyingValue: (nil, second) as (T0?, T1?))
    }

    public init<T0, T1, T2>(_ first: T0) where T == (T0, T1, T2) {
        self.init(_underlyingValue: (first, nil, nil) as (T0?, T1?, T2?))
    }
    
    public init<T0, T1, T2>(_ first: T0) where T == (T0?, T1?, T2?) {
        self.init(_underlyingValue: (first, nil, nil) as (T0?, T1?, T2?))
    }
    
    public init<T0, T1, T2>(_ second: T1) where T == (T0, T1, T2) {
        self.init(_underlyingValue: (nil, second, nil) as (T0?, T1?, T2?))
    }
    
    public init<T0, T1, T2>(_ second: T1) where T == (T0?, T1?, T2?) {
        self.init(_underlyingValue: (nil, second, nil) as (T0?, T1?, T2?))
    }
    
    public init<T0, T1, T2>(_ third: T2) where T == (T0, T1, T2) {
        self.init(_underlyingValue: (nil, nil, third) as (T0?, T1?, T2?))
    }
    
    public init<T0, T1, T2>(_ third: T2) where T == (T0?, T1?, T2?) {
        self.init(_underlyingValue: (nil, nil, third) as (T0?, T1?, T2?))
    }
}
