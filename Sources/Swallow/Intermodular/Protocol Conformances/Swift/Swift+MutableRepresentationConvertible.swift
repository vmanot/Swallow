//
// Copyright (c) Vatsal Manot
//

import Swift

extension UnsafeBufferPointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafeBufferPointer<Element>
    public typealias MutableRepresentation = UnsafeMutableBufferPointer<Element>
}

extension UnsafeMutableBufferPointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafeBufferPointer<Element>
    public typealias MutableRepresentation = UnsafeMutableBufferPointer<Element>
}

extension UnsafeMutablePointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafePointer<Pointee>
    public typealias MutableRepresentation = UnsafeMutablePointer<Pointee>
}

extension UnsafeMutableRawBufferPointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafeRawBufferPointer
    public typealias MutableRepresentation = UnsafeMutableRawBufferPointer
}

extension UnsafeMutableRawPointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafeRawPointer
    public typealias MutableRepresentation = UnsafeMutableRawPointer
}

extension UnsafePointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafePointer<Pointee>
    public typealias MutableRepresentation = UnsafeMutablePointer<Pointee>
}

extension UnsafeRawBufferPointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafeRawBufferPointer
    public typealias MutableRepresentation = UnsafeMutableRawBufferPointer
}

extension UnsafeRawPointer: MutableRepresentationConvertible {
    public typealias ImmutableRepresentation = UnsafeRawPointer
    public typealias MutableRepresentation = UnsafeMutableRawPointer
}

// MARK: - Helpers

extension InitiableBufferPointer where Self: MutableBufferPointer & MutableRepresentationConvertible, Self.ImmutableRepresentation: InitiableBufferPointer & ConstantBufferPointer, Self.ImmutableRepresentation.Element == Self.Element {
    @inlinable
    public var immutableRepresentation: ImmutableRepresentation {
        get {
            return .init(self)
        } set {
            self = _reinterpretCast(newValue)
        }
    }
}

extension InitiableBufferPointer where Self: MutableRepresentationConvertible, Self.MutableRepresentation: InitiableBufferPointer & MutableBufferPointer {
    @inlinable
    public var mutableRepresentation: MutableRepresentation {
        get {
            return _reinterpretCast(self)
        } set {
            self = _reinterpretCast(newValue)
        }
    }
}

extension Pointer where Self: MutableRepresentationConvertible, Self.ImmutableRepresentation: ConstantPointer {
    @inlinable
    public var immutableRepresentation: ImmutableRepresentation {
        get {
            return .init(opaquePointerRepresentation)
        } set {
            self = .init(newValue.opaquePointerRepresentation)
        }
    }
}

extension Pointer where Self: MutableRepresentationConvertible, Self.MutableRepresentation: MutablePointer {
    @inlinable
    public var mutableRepresentation: MutableRepresentation {
        get {
            return .init(opaquePointerRepresentation)
        } set {
            self = .init(newValue.opaquePointerRepresentation)
        }
    }
}
