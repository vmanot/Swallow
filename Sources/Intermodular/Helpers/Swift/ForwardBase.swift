//
// Copyright (c) Vatsal Manot
//

import Swift

open class ForwardBase<Base> {
    open var debugInformation: DebugInformation
    open var base: Base

    public init(base: Base, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) {
        self.debugInformation = .init(file: file, function: function, line: line, column: column)
        self.base = base
    }

    public func performNonmutatingFunction<T, U>(_ x: T, _ f: ((T) throws -> U)) rethrows -> U {
        return try f(x)
    }

    public func performNonmutatingFunctionMutatingParameter<T, U>(_ x: inout T, _ f: ((inout T) throws -> U)) rethrows -> U {
        return try f(&x)
    }

    public func performNonmutatingFunctionParameterUnavailable<T>(_ f: (() throws -> T)) rethrows -> T {
        return try f()
    }

    public func performMutatingFunction<T, U>(_ x: T, _ f: ((T) throws -> U)) rethrows -> U {
        return try f(x)
    }

    public func performMutatingFunctionMutatingParameter<T, U>(_ x: inout T, _ f: ((inout T) throws -> U)) rethrows -> U {
        return try f(&x)
    }

    public func performMutatingFunctionParameterUnavailable<T>(_ f: (() throws -> T)) rethrows -> T {
        return try f()
    }
}

// MARK: - Base -

extension ForwardBase: CustomStringConvertible where Base: CustomStringConvertible {
    public var description: String {
        return base.description
    }
}

extension ForwardBase: CustomDebugStringConvertible where Base: CustomDebugStringConvertible {
    public var description: String {
        return base.debugDescription
    }
}

extension ForwardBase: BidirectionalCollection where Base: BidirectionalCollection {
    public func index(before i: Index) -> Index {
        return performNonmutatingFunction(i, base.index(before:))
    }
}

extension ForwardBase: Collection where Base: Collection {
    public typealias Index = Base.Index
    public typealias SubSequence = Base.SubSequence

    public var startIndex: Index {
        return performNonmutatingFunction((), { base.startIndex })
    }

    public var endIndex: Index {
        return performNonmutatingFunction((), { base.endIndex })
    }

    public func index(after i: Index) -> Index {
        return performNonmutatingFunction(i, base.index(after:))
    }

    public subscript(bounds: Range<Index>) -> SubSequence {
        return performNonmutatingFunction(bounds) {
            base[$0]
        }
    }

    public subscript(position: Index) -> Element {
        return performNonmutatingFunction(position) {
            base[$0]
        }
    }
}

extension ForwardBase: MutableCollection where Base: MutableCollection {
    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            return performNonmutatingFunction(bounds) {
                base[$0]
            }
        } set {
            performMutatingFunction(bounds) {
                base[$0] = newValue
            }
        }
    }

    public subscript(position: Index) -> Element {
        get {
            return performNonmutatingFunction(position) {
                base[$0]
            }
        } set {
            performMutatingFunction(position) {
                base[$0] = newValue
            }
        }
    }
}

extension ForwardBase: RandomAccessCollection where Base: RandomAccessCollection {
    public func index(before i: Index) -> Index {
        return performNonmutatingFunction(i, base.index(before:))
    }

    public func formIndex(before i: inout Index) {
        return performNonmutatingFunctionMutatingParameter(&i) {
            base.formIndex(before: &$0)
        }
    }

    public func index(after i: Index) -> Index {
        return performNonmutatingFunction(i, base.index(after:))
    }

    public func formIndex(after i: inout Index) {
        return performNonmutatingFunctionMutatingParameter(&i) {
            base.formIndex(after: &$0)
        }
    }

    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        return performNonmutatingFunction((i, distance), base.index)
    }

    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        return performNonmutatingFunction((i, distance, limit), base.index)
    }

    public func distance(from start: Index, to end: Index) -> Int {
        return performNonmutatingFunction((start, end), base.distance)
    }
}

extension ForwardBase: Sequence where Base: Sequence {
    public typealias Element = Base.Element
    public typealias Iterator = Base.Iterator

    public func makeIterator() -> Base.Iterator {
        return performNonmutatingFunction((), base.makeIterator)
    }
}
