//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_SetProtocol {
    func opaque_SetProtocol_isSubset(of _: Any) -> Bool?
    func opaque_SetProtocol_isSuperset(of _: Any) -> Bool?
}

public protocol opaque_SequenceInitiableSetProtocol: opaque_SequenceInitiableSequence {
    func opaque_SequenceInitiableSetProtocol_intersection(_: Any) -> Any?
    func opaque_SequenceInitiableSetProtocol_union(_: Any) -> Any?
}

public protocol opaque_MutableSetProtocol: opaque_MutableSequence, opaque_SetProtocol {
    
}

public protocol opaque_ExtensibleSetProtocol: opaque_ExtensibleSequence, opaque_SetProtocol {
    
}

public protocol opaque_DestructivelyMutableSetProtocol: opaque_DestructivelyMutableSequence, opaque_MutableSetProtocol {
    
}

public protocol opaque_ResizableSetProtocol: opaque_DestructivelyMutableSetProtocol, opaque_ExtensibleSetProtocol, opaque_ResizableSequence, opaque_SequenceInitiableSetProtocol {
    
}

// MARK: - Implementation -

extension opaque_DestructivelyMutableSequence where Self: DestructivelyMutableSequence {
    public mutating func opaque_DestructivelyMutableSequence_forEach<T>(mutating iterator: ((inout Any?) throws -> T)) rethrows {
        try forEach(mutating: {
            var _element: Any? = $0
            _ = try iterator(&_element)
            $0 = _element.map({ try! cast($0) })
        })
    }
}

// MARK: -

extension opaque_ExtensibleSequence where Self: ExtensibleSequence {
    public mutating func opaque_ExtensibleSequence_insert(_ newElement: Any) -> Any? {
        return (-?>newElement).map({ insert($0) })
    }

    public mutating func opaque_ExtensibleSequence_insert(contentsOf newElements: Any) -> Any? {
        return ((newElements as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map({ insert(contentsOf: $0) })
    }

    public mutating func opaque_ExtensibleSequence_append(_ newElement: Any) -> Any? {
        return (-?>newElement).map({ append($0) })
    }

    public mutating func opaque_ExtensibleSequence_append(contentsOf newElements: Any) -> Any? {
        return ((newElements as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map({ append(contentsOf: $0) })
    }
}

// MARK: -

extension opaque_MutableSequence where Self: MutableSequence {
    public mutating func opaque_MutableSequence_forEach<T>(mutating iterator: ((inout Any) throws -> T)) rethrows {
        try forEach {
            (element: inout Element) in
            var _element: Any = element
            _ = try iterator(&_element)
            element = try! cast(_element)
        }
    }
}

// MARK: -

extension opaque_SequenceInitiableSequence where Self: SequenceInitiableSequence {
    public static func opaque_SequenceInitiableSequence_init(_ sequence: Any) -> opaque_SequenceInitiableSequence? {
        return ((sequence as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map({ self.init($0) })
    }
}

// MARK: -

extension opaque_SetProtocol where Self: SetProtocol {
    public func opaque_SetProtocol_isSubset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSubset(of:))
    }

    public func opaque_SetProtocol_isSuperset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSuperset(of:))
    }
}

extension opaque_SetProtocol where Self: SequenceInitiableSetProtocol {
    public func opaque_SetProtocol_isSubset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSubset(of:)) ?? ((other as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map(isSubset(of:))
    }

    public func opaque_SetProtocol_isSuperset(of other: Any) -> Bool? {
        return (-?>other as Self?).map(isSuperset(of:)) ?? ((other as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map(isSuperset(of:))
    }
}

extension opaque_SequenceInitiableSetProtocol where Self: SequenceInitiableSetProtocol {
    public func opaque_SequenceInitiableSetProtocol_intersection(_ other: Any) -> Any? {
        return (-?>other as Self?).map(intersection) ?? ((other as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map(intersection)
    }

    public func opaque_SequenceInitiableSetProtocol_union(_ other: Any) -> Any? {
        return (-?>other as Self?).map(union) ?? ((other as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map(union)
    }
}

