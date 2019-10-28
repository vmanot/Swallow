//
// Copyright (c) Vatsal Manot
//

import Swift

extension UnsafeBufferPointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafeBufferPointer<Element>
    public typealias MutableRepresentation = UnsafeMutableBufferPointer<Element>
}

extension UnsafeMutableBufferPointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafeBufferPointer<Element>
    public typealias MutableRepresentation = UnsafeMutableBufferPointer<Element>
}

extension UnsafeMutablePointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafePointer<Pointee>
    public typealias MutableRepresentation = UnsafeMutablePointer<Pointee>
}

extension UnsafeMutableRawBufferPointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafeRawBufferPointer
    public typealias MutableRepresentation = UnsafeMutableRawBufferPointer
}

extension UnsafeMutableRawPointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafeRawPointer
    public typealias MutableRepresentation = UnsafeMutableRawPointer
}

extension UnsafePointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafePointer<Pointee>
    public typealias MutableRepresentation = UnsafeMutablePointer<Pointee>
}

extension UnsafeRawBufferPointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafeRawBufferPointer
    public typealias MutableRepresentation = UnsafeMutableRawBufferPointer
}

extension UnsafeRawPointer: MutableConvertible {
    public typealias ImmutableRepresentation = UnsafeRawPointer
    public typealias MutableRepresentation = UnsafeMutableRawPointer
}

// MARK: - Helpers -

extension InitiableBufferPointer where Self: MutableBufferPointer & MutableConvertible, Self.ImmutableRepresentation: InitiableBufferPointer & ConstantBufferPointer, Self.ImmutableRepresentation.Element == Self.Element {
    @inlinable
    public var immutableRepresentation: ImmutableRepresentation {
        get {
            return .init(self)
        } set {
            self = reinterpretCast(newValue)
        }
    }
}

extension InitiableBufferPointer where Self: MutableConvertible, Self.MutableRepresentation: InitiableMutableBufferPointer {
    @inlinable
    public var mutableRepresentation: MutableRepresentation {
        get {
            return reinterpretCast(self)
        } set {
            self = reinterpretCast(newValue)
        }
    }
}

extension Pointer where Self: MutableConvertible, Self.ImmutableRepresentation: ConstantPointer {
    @inlinable
    public var immutableRepresentation: ImmutableRepresentation {
        get {
            return .init(opaquePointerRepresentation)
        } set {
            self = .init(newValue.opaquePointerRepresentation)
        }
    }
}

extension Pointer where Self: MutableConvertible, Self.MutableRepresentation: MutablePointer {
    @inlinable
    public var mutableRepresentation: MutableRepresentation {
        get {
            return .init(opaquePointerRepresentation)
        } set {
            self = .init(newValue.opaquePointerRepresentation)
        }
    }
}
