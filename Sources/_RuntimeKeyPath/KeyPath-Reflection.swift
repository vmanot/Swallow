//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftShims

// A way to emulate the behavior of `Builtin.projectTailElems` without actually
// calling that function. Treat the class like a pointer to a pointer, then
// increment the second-level pointer by `tailAllocOffset`. This is used in
// `AnyKeyPath._create`.
//
// On development toolchains, using `Builtin.projectTailElems` causes a compiler
// crash (see https://github.com/apple/swift/issues/59118 for more info). On
// release toolchains, it strangely does a 16-byte offset instead of the correct
// 24-byte offset (why?). I have not tested this on 32-bit platforms, but I
// assume the 24-byte offset is just 3 pointers.
internal let tailAllocOffset = 3 * MemoryLayout<Int>.stride

// Workaround for the fact that `_kvcKeyPathStringPtr` is internal to the Swift
// standard library.
fileprivate class AnyKeyPathFaux {
    final var _kvcKeyPathStringPtr: UnsafePointer<CChar>?
}

@_spi(Internal)
extension AnyKeyPath {
    public static func _create(
        capacityInBytes bytes: Int,
        initializedBy body: (UnsafeMutableRawBufferPointer) -> Void
    ) -> Self {
        _internalInvariant(bytes > 0 && bytes % 4 == 0,
                           "capacity must be multiple of 4 bytes \(bytes)")
        let result = Builtin.allocWithTailElems_1(self, (bytes/4)._builtinWordValue,
                                                  Int32.self)
        let unmanaged = Unmanaged.passUnretained(result).toOpaque()
        
        //    result._kvcKeyPathStringPtr = nil
        let unmanagedFaux = Unmanaged<AnyKeyPathFaux>.fromOpaque(unmanaged)
        unmanagedFaux.takeUnretainedValue()._kvcKeyPathStringPtr = nil
        
        //    let base = UnsafeMutableRawPointer(Builtin.projectTailElems(result,
        //                                                                Int32.self))
        let base = unmanaged.advanced(by: tailAllocOffset)
        body(UnsafeMutableRawBufferPointer(start: base, count: bytes))
        return result
    }
    
}

// MARK: Implementation details

@_spi(Internal)
public enum KeyPathComponentKind {
    /// The keypath references an externally-defined property or subscript whose
    /// component describes how to interact with the key path.
    case external
    /// The keypath projects within the storage of the outer value, like a
    /// stored property in a struct.
    case `struct`
    /// The keypath projects from the referenced pointer, like a
    /// stored property in a class.
    case `class`
    /// The keypath projects using a getter/setter pair.
    case computed
    /// The keypath optional-chains, returning nil immediately if the input is
    /// nil, or else proceeding by projecting the value inside.
    case optionalChain
    /// The keypath optional-forces, trapping if the input is
    /// nil, or else proceeding by projecting the value inside.
    case optionalForce
    /// The keypath wraps a value in an optional.
    case optionalWrap
}

@_spi(Internal)
public struct RawKeyPathComponent {
    public var header: Header
    public var body: UnsafeRawBufferPointer
    
    public init(header: Header, body: UnsafeRawBufferPointer) {
        self.header = header
        self.body = body
    }
    
    public struct Header {
        public var _value: UInt32
        
        public init(discriminator: UInt32, payload: UInt32) {
            _value = 0
            self.discriminator = discriminator
            self.payload = payload
        }
        
        public var discriminator: UInt32 {
            get {
                return (_value & Header.discriminatorMask) >> Header.discriminatorShift
            }
            set {
                let shifted = newValue << Header.discriminatorShift
                _internalInvariant(shifted & Header.discriminatorMask == shifted,
                                   "discriminator doesn't fit")
                _value = _value & ~Header.discriminatorMask | shifted
            }
        }
        public var storedOffsetPayload: UInt32 {
            get {
                _internalInvariant(kind == .struct || kind == .class,
                                   "not a stored component")
                return _value & Header.storedOffsetPayloadMask
            }
            set {
                _internalInvariant(kind == .struct || kind == .class,
                                   "not a stored component")
                _internalInvariant(newValue & Header.storedOffsetPayloadMask == newValue,
                                   "payload too big")
                _value = _value & ~Header.storedOffsetPayloadMask | newValue
            }
        }
        public var payload: UInt32 {
            get {
                return _value & Header.payloadMask
            }
            set {
                _internalInvariant(newValue & Header.payloadMask == newValue,
                                   "payload too big")
                _value = _value & ~Header.payloadMask | newValue
            }
        }
        public var endOfReferencePrefix: Bool {
            get {
                return _value & Header.endOfReferencePrefixFlag != 0
            }
            set {
                if newValue {
                    _value |= Header.endOfReferencePrefixFlag
                } else {
                    _value &= ~Header.endOfReferencePrefixFlag
                }
            }
        }
        
        public var kind: KeyPathComponentKind {
            switch (discriminator, payload) {
                case (Header.externalTag, _):
                    return .external
                case (Header.structTag, _):
                    return .struct
                case (Header.classTag, _):
                    return .class
                case (Header.computedTag, _):
                    return .computed
                case (Header.optionalTag, Header.optionalChainPayload):
                    return .optionalChain
                case (Header.optionalTag, Header.optionalWrapPayload):
                    return .optionalWrap
                case (Header.optionalTag, Header.optionalForcePayload):
                    return .optionalForce
                default:
                    _internalInvariantFailure("invalid header")
            }
        }
        
        public static var payloadMask: UInt32 {
            return _SwiftKeyPathComponentHeader_PayloadMask
        }
        public static var discriminatorMask: UInt32 {
            return _SwiftKeyPathComponentHeader_DiscriminatorMask
        }
        public static var discriminatorShift: UInt32 {
            return _SwiftKeyPathComponentHeader_DiscriminatorShift
        }
        public static var externalTag: UInt32 {
            return _SwiftKeyPathComponentHeader_ExternalTag
        }
        public static var structTag: UInt32 {
            return _SwiftKeyPathComponentHeader_StructTag
        }
        public static var computedTag: UInt32 {
            return _SwiftKeyPathComponentHeader_ComputedTag
        }
        public static var classTag: UInt32 {
            return _SwiftKeyPathComponentHeader_ClassTag
        }
        public static var optionalTag: UInt32 {
            return _SwiftKeyPathComponentHeader_OptionalTag
        }
        public static var optionalChainPayload: UInt32 {
            return _SwiftKeyPathComponentHeader_OptionalChainPayload
        }
        public static var optionalWrapPayload: UInt32 {
            return _SwiftKeyPathComponentHeader_OptionalWrapPayload
        }
        public static var optionalForcePayload: UInt32 {
            return _SwiftKeyPathComponentHeader_OptionalForcePayload
        }
        
        public static var endOfReferencePrefixFlag: UInt32 {
            return _SwiftKeyPathComponentHeader_EndOfReferencePrefixFlag
        }
        public static var storedMutableFlag: UInt32 {
            return _SwiftKeyPathComponentHeader_StoredMutableFlag
        }
        public static var storedOffsetPayloadMask: UInt32 {
            return _SwiftKeyPathComponentHeader_StoredOffsetPayloadMask
        }
        public static var outOfLineOffsetPayload: UInt32 {
            return _SwiftKeyPathComponentHeader_OutOfLineOffsetPayload
        }
        public static var unresolvedFieldOffsetPayload: UInt32 {
            return _SwiftKeyPathComponentHeader_UnresolvedFieldOffsetPayload
        }
        public static var unresolvedIndirectOffsetPayload: UInt32 {
            return _SwiftKeyPathComponentHeader_UnresolvedIndirectOffsetPayload
        }
        public static var maximumOffsetPayload: UInt32 {
            return _SwiftKeyPathComponentHeader_MaximumOffsetPayload
        }
        
        // The component header is 4 bytes, but may be followed by an aligned
        // pointer field for some kinds of component, forcing padding.
        public static var pointerAlignmentSkew: Int {
            return MemoryLayout<Int>.size - MemoryLayout<Int32>.size
        }
        
        public init(
            stored kind: KeyPathStructOrClass,
            mutable: Bool,
            inlineOffset: UInt32
        ) {
            let discriminator: UInt32
            switch kind {
                case .struct: discriminator = Header.structTag
                case .class: discriminator = Header.classTag
            }
            
            _internalInvariant(inlineOffset <= Header.maximumOffsetPayload)
            let payload = inlineOffset
            | (mutable ? Header.storedMutableFlag : 0)
            self.init(
                discriminator: discriminator,
                payload: payload
            )
        }
    }
    
    public func clone(
        into buffer: inout UnsafeMutableRawBufferPointer,
        endOfReferencePrefix: Bool
    ) {
        var newHeader = header
        newHeader.endOfReferencePrefix = endOfReferencePrefix
        
        var componentSize = MemoryLayout<Header>.size
        buffer.storeBytes(of: newHeader, as: Header.self)
        switch header.kind {
            case .struct,
                    .class:
                if header.storedOffsetPayload == Header.outOfLineOffsetPayload {
                    let overflowOffset = body.load(as: UInt32.self)
                    buffer.storeBytes(of: overflowOffset, toByteOffset: 4,
                                      as: UInt32.self)
                    componentSize += 4
                }
                break
            case .optionalChain,
                    .optionalForce,
                    .optionalWrap:
                break
            case .computed:
                // Metadata does not have enough information to construct computed
                // properties. In the Swift stdlib, this case would trigger a large block
                // of code. That code is left out because it is not necessary.
                fatalError("Implement support for key paths to computed properties.")
                break
            case .external:
                _internalInvariantFailure("should have been instantiated away")
        }
        buffer = UnsafeMutableRawBufferPointer(
            start: buffer.baseAddress.unsafelyUnwrapped + componentSize,
            count: buffer.count - componentSize)
    }
}

public struct KeyPathBuffer {
    public struct Builder {
        public var buffer: UnsafeMutableRawBufferPointer
        
        public init(_ buffer: UnsafeMutableRawBufferPointer) {
            self.buffer = buffer
        }
        
        public mutating func pushRaw(
            size: Int, alignment: Int
        ) -> UnsafeMutableRawBufferPointer {
            var baseAddress = buffer.baseAddress.unsafelyUnwrapped
            var misalign = Int(bitPattern: baseAddress) & (alignment - 1)
            if misalign != 0 {
                misalign = alignment - misalign
                baseAddress = baseAddress.advanced(by: misalign)
            }
            let result = UnsafeMutableRawBufferPointer(
                start: baseAddress,
                count: size)
            buffer = UnsafeMutableRawBufferPointer(
                start: baseAddress + size,
                count: buffer.count - size - misalign)
            return result
        }
        
        public mutating func push<T>(
            _ value: T
        ) {
            let buf = pushRaw(
                size: MemoryLayout<T>.size,
                alignment: MemoryLayout<T>.alignment
            )
            buf.storeBytes(of: value, as: T.self)
        }
        
        public mutating func pushHeader(_ header: Header) {
            push(header)
            // Start the components at pointer alignment
            _ = pushRaw(
                size: RawKeyPathComponent.Header.pointerAlignmentSkew,
                alignment: 4
            )
        }
    }
    
    public struct Header {
        public var _value: UInt32
        
        public init(
            size: Int,
            trivial: Bool,
            hasReferencePrefix: Bool
        ) {
            _internalInvariant(size <= Int(Header.sizeMask),
                               "key path too big")
            _value = UInt32(size)
            | (trivial ? Header.trivialFlag : 0)
            | (hasReferencePrefix ? Header.hasReferencePrefixFlag : 0)
        }
        
        public static var sizeMask: UInt32 {
            return _SwiftKeyPathBufferHeader_SizeMask
        }
        
        public static var reservedMask: UInt32 {
            return _SwiftKeyPathBufferHeader_ReservedMask
        }
        
        public static var trivialFlag: UInt32 {
            return _SwiftKeyPathBufferHeader_TrivialFlag
        }
        
        public static var hasReferencePrefixFlag: UInt32 {
            return _SwiftKeyPathBufferHeader_HasReferencePrefixFlag
        }
    }
}

public enum KeyPathStructOrClass {
    case `struct`, `class`
}
