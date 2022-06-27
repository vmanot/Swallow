//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol InitiableBufferPointer: BufferPointer {
    init(start _: BaseAddressPointer?, count: Int)

    static func allocate(capacity: Int) -> Self

    static func initializing(from _: BaseAddressPointer, count: Int) -> Self

    static func initializing<S: Sequence>(from _: S) -> Self where S.Element == Element
    static func initializing<S: Sequence>(from _: S, count: Int) -> Self where S.Element == Element

    static func initializing<C: Collection>(from _: C) -> Self where C.Element == Element
    static func initializing<C: Collection>(from _: C, count: Int) -> Self where C.Element == Element
}

// MARK: - Implementation -

extension InitiableBufferPointer {
    public static func allocate(capacity: Int) -> Self {
        return self.init(start: .init(UnsafeMutablePointer<Element>.allocate(capacity: numericCast(capacity))), count: capacity)
    }
}

extension InitiableBufferPointer {
    public static func initializing(from start: BaseAddressPointer, count: Int) -> Self {
        let result = allocate(capacity: count)

        result.baseAddress?.unsafeMutablePointerRepresentation.assign(from: start.unsafePointerRepresentation, count: numericCast(count))

        return result
    }

    public static func initializing<S: Sequence>(from sequence: S) -> Self where S.Element == Element {
        return initializing(from: sequence.toFauxCollection())
    }

    public static func initializing<S: Sequence>(from sequence: S, count: Int) -> Self where S.Element == Element {
        guard count != 0 else {
            return .init(start: nil, count: 0)
        }

        let rawBufferPointer = UnsafeMutableBufferPointer<Element>.allocate(capacity: numericCast(count))

        _ = rawBufferPointer.initialize(from: sequence)

        return .init(start: rawBufferPointer.baseAddress, count: count)
    }

    public static func initializing<C: Collection>(from collection: C) -> Self where C.Element == Element {
        return initializing(from: collection, count: numericCast(collection.count))
    }

    public static func initializing<C: Collection>(from collection: C, count: Int) -> Self where C.Element == Element {
        return initializing(from: AnySequence(collection), count: count)
    }
}

// MARK: - Extensions -

extension InitiableBufferPointer {
    public init(start: BaseAddressPointer, count: Int) {
        self.init(start: Optional(start), count: count)
    }

    public init<P: MutablePointer>(start: P, count: Int) where P.Pointee == Element {
        self.init(start: BaseAddressPointer(start), count: count)
    }

    public init<P: MutablePointer>(start: P?, count: Int) where P.Pointee == Element {
        self.init(start: start.map(BaseAddressPointer.init), count: count)
    }

    public init<P: MutablePointer, N: BinaryInteger>(start: P, count: N) where P.Pointee == Element {
        self.init(start: start, count: numericCast(count))
    }

    public init<P: MutablePointer, N: BinaryInteger>(start: P?, count: N) where P.Pointee == Element {
        self.init(start: start, count: numericCast(count))
    }

    public init<BP: MutableBufferPointer>(_ bufferPointer: BP) where BP.Element == Element {
        self.init(start: BaseAddressPointer(bufferPointer.baseAddress), count: numericCast(bufferPointer.count))
    }
}

extension InitiableBufferPointer where Self: ConstantBufferPointer {
    public init<P: Pointer>(start: P, count: Int) where P.Pointee == Element {
        self.init(start: BaseAddressPointer(start), count: count)
    }

    public init<P: Pointer>(start: P?, count: Int) where P.Pointee == Element {
        self.init(start: start.map(BaseAddressPointer.init), count: count)
    }

    public init<P: Pointer, N: BinaryInteger>(start: P, count: N) where P.Pointee == Element {
        self.init(start: start, count: numericCast(count))
    }

    public init<P: Pointer, N: BinaryInteger>(start: P?, count: N) where P.Pointee == Element {
        self.init(start: start, count: numericCast(count))
    }

    public init<P: MutablePointer>(start: P, count: Int) where P.Pointee == Element {
        self.init(start: BaseAddressPointer(start), count: count)
    }

    public init<P: MutablePointer>(start: P?, count: Int) where P.Pointee == Element {
        self.init(start: start.map(BaseAddressPointer.init), count: count)
    }

    public init<P: MutablePointer, N: BinaryInteger>(start: P, count: N) where P.Pointee == Element {
        self.init(start: start, count: numericCast(count))
    }

    public init<P: MutablePointer, N: BinaryInteger>(start: P?, count: N) where P.Pointee == Element {
        self.init(start: start, count: numericCast(count))
    }

    public init<BP: BufferPointer>(_ bufferPointer: BP) where BP.Element == Element {
        self.init(start: BaseAddressPointer(bufferPointer.baseAddress), count: numericCast(bufferPointer.count))
    }
}

extension InitiableBufferPointer {
    public static func allocate<N: BinaryInteger>(capacity: N) -> Self {
        return allocate(capacity: numericCast(capacity))
    }
}

extension InitiableBufferPointer {
    public static func to<T>(assumingLayoutCompatible value: inout T) -> Self {
        return .init(start: .to(assumingLayoutCompatible: &value), count: numericCast(MemoryLayout<T>.stride / MemoryLayout<Element>.stride))
    }
}

// MARK: - Helpers -

@inlinable
public func reinterpretCast<T: InitiableBufferPointer, U: InitiableBufferPointer>(_ x: T) -> U? {
    return U.init(start: -?>x.baseAddress, count: x.count)
}

@inlinable
public func reinterpretCast<T: InitiableBufferPointer, U: InitiableBufferPointer>(_ x: T) -> U {
    return U.init(start: -?>x.baseAddress, count: (x.count.toDouble() * MemoryLayout<T.Element>.size.toDouble() / MemoryLayout<U.Element>.size.toDouble()).toInt())
}
