//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_SetProtocol {
    func _opaque_SetProtocol_isSubset(of _: Any) -> Bool?
    func _opaque_SetProtocol_isSuperset(of _: Any) -> Bool?
}

public protocol _opaque_SequenceInitiableSetProtocol: _opaque_SequenceInitiableSequence {
    func _opaque_SequenceInitiableSetProtocol_intersection(_: Any) -> Any?
    func _opaque_SequenceInitiableSetProtocol_union(_: Any) -> Any?
}

public protocol _opaque_MutableSetProtocol: _opaque_MutableSequence, _opaque_SetProtocol {
    
}

public protocol _opaque_ExtensibleSetProtocol: _opaque_ExtensibleSequence, _opaque_SetProtocol {
    
}

public protocol _opaque_DestructivelyMutableSetProtocol: _opaque_DestructivelyMutableSequence, _opaque_MutableSetProtocol {
    
}

public protocol _opaque_ResizableSetProtocol: _opaque_DestructivelyMutableSetProtocol, _opaque_ExtensibleSetProtocol, _opaque_ResizableSequence, _opaque_SequenceInitiableSetProtocol {
    
}

// MARK: - Implementation -

extension _opaque_DestructivelyMutableSequence where Self: DestructivelyMutableSequence {
    public mutating func _opaque_DestructivelyMutableSequence_forEach<T>(mutating iterator: ((inout Any?) throws -> T)) rethrows {
        try forEach(mutating: {
            var _element: Any? = $0
            _ = try iterator(&_element)
            $0 = _element.map({ try! cast($0) })
        })
    }
}

// MARK: -

extension _opaque_ExtensibleSequence where Self: ExtensibleSequence {
    public mutating func _opaque_ExtensibleSequence_insert(_ newElement: Any) -> Any? {
        return (-?>newElement).map({ insert($0) })
    }
    
    public mutating func _opaque_ExtensibleSequence_insert(contentsOf newElements: Any) -> Any? {
        return ((newElements as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence).map({ insert(contentsOf: $0) })
    }
    
    public mutating func _opaque_ExtensibleSequence_append(_ newElement: Any) -> Any? {
        return (-?>newElement).map({ append($0) })
    }
    
    public mutating func _opaque_ExtensibleSequence_append(contentsOf newElements: Any) -> Any? {
        return ((newElements as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence).map({ append(contentsOf: $0) })
    }
}

// MARK: -

extension _opaque_MutableSequence where Self: MutableSequence {
    public mutating func _opaque_MutableSequence_forEach<T>(mutating iterator: ((inout Any) throws -> T)) rethrows {
        try forEach {
            (element: inout Element) in
            var _element: Any = element
            _ = try iterator(&_element)
            element = try! cast(_element)
        }
    }
}

// MARK: -

extension _opaque_SequenceInitiableSequence where Self: SequenceInitiableSequence {
    public static func _opaque_SequenceInitiableSequence_init(_ sequence: Any) -> _opaque_SequenceInitiableSequence? {
        return ((sequence as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence).map({ self.init($0) })
    }
}

// MARK: -

extension _opaque_SetProtocol where Self: SetProtocol {
    public func _opaque_SetProtocol_isSubset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSubset(of:))
    }
    
    public func _opaque_SetProtocol_isSuperset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSuperset(of:))
    }
}

extension _opaque_SetProtocol where Self: SequenceInitiableSetProtocol {
    public func _opaque_SetProtocol_isSubset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSubset(of:)) ?? ((other as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence).map(isSubset(of:))
    }
    
    public func _opaque_SetProtocol_isSuperset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSuperset(of:)) ?? ((other as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence).map(isSuperset(of:))
    }
}

extension _opaque_SequenceInitiableSetProtocol where Self: SequenceInitiableSetProtocol {
    public func _opaque_SequenceInitiableSetProtocol_intersection(_ other: Any) -> Any? {
        return (-?>other as Self?).map(intersection) ?? ((other as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence).map(intersection)
    }
    
    public func _opaque_SequenceInitiableSetProtocol_union(_ other: Any) -> Any? {
        return (-?>other as Self?).map(union) ?? ((other as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence).map(union)
    }
}
