//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _ComplexPropertyWrapper: MutablePropertyWrapper {
    associatedtype _WrappedValue
    
    typealias WrappedValueAccessor = _ComplexPropertyWrapperValueAccessor<Self>
    
    var _wrappedValueAccessor: WrappedValueAccessor { get }
}

// MARK: - Implementation -

extension _ComplexPropertyWrapper {
    public var wrappedValue: WrappedValue {
        get {
            _wrappedValueAccessor.get(self)
        } set {
            _wrappedValueAccessor.set(&self, newValue)
        }
    }
}

// MARK: - Auxiliary Implementation -

public struct _ComplexPropertyWrapperValueAccessor<Wrapper: _ComplexPropertyWrapper> {
    fileprivate let _wrappedValue: Wrapper._WrappedValue
    fileprivate let get: (Wrapper) -> Wrapper.WrappedValue
    fileprivate let set: (inout Wrapper, Wrapper.WrappedValue) -> Void
}
