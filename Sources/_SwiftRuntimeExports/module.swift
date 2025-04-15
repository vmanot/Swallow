//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@_silgen_name("swift_isClassType")
public func swift_isClassType(_: Any.Type) -> Bool

@_silgen_name("swift_isClassType")
public func swift_isClassType(_: Any.Type) -> Bool

#if canImport(ObjectiveC)
@_silgen_name("swift_getInitializedObjCClass")
public func _swift_getInitializedObjCClass(_ c: AnyClass!) -> AnyClass!
#else
public func _swift_getInitializedObjCClass(_ c: AnyClass!) -> AnyClass! {
    fatalError(Never.Reason.unavailable)
}
#endif

@_silgen_name("swift_conformsToProtocol")
public func _swift_conformsToProtocol(
    _ type: Any.Type,
    _ protocolDescriptor: UnsafeRawPointer
) -> UnsafeRawPointer?

@_silgen_name("swift_getExistentialMetatypeMetadata")
public func _swift_getExistentialMetatypeMetadata(
    _ instanceType: Any.Type
) -> Any.Type?

@_silgen_name("$ss24_forEachFieldWithKeyPath2of7options4bodySbxm_s01_bC7OptionsVSbSPys4Int8VG_s07PartialeF0CyxGtXEtlF")
public func _forEachFieldWithKeyPath<Root>(
    of type: Root.Type,
    options: UnsafePointer<_SwiftRuntimeEachFieldOptions>,
    body: (UnsafePointer<CChar>, PartialKeyPath<Root>) -> Bool
) -> Bool

@_silgen_name("swift_reinterpretCast")
public func _swift_reinterpretCast<T>(
    _ val: Any
) -> UnsafePointer<T>

@_silgen_name("swift_reflectionMirror_normalizedType")
public func _swift_reflectionMirror_normalizedType<T>(_: T, type: Any.Type) -> Any.Type

@_silgen_name("swift_reflectionMirror_recursiveCount")
public func _swift_reflectionMirror_recursiveCount(
    _: Any.Type
) -> Int

@_silgen_name("swift_reflectionMirror_recursiveChildMetadata")
public func _swift_reflectionMirror_recursiveChildMetadata(
    _: Any.Type
    , index: Int
    , fieldMetadata: UnsafeMutablePointer<_SwiftRuntimeTypeFieldReflectionMetadata>
) -> Any.Type

@_silgen_name("swift_reflectionMirror_recursiveChildOffset")
public func _swift_reflectionMirror_recursiveChildOffset(
    _: Any.Type,
    index: Int
) -> Int

@_silgen_name("swift_getMetadataKind")
public func _swift_getMetadataKind(_: Any.Type) -> UInt

@_silgen_name("swift_demangle")
@_spi(Internal)
public func _stdlib_demangleImpl(
    mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<CChar>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("swift_getTypeByMangledNameInContext")
public func _swift_getTypeByMangledNameInContext(
    _ name: UnsafePointer<CChar>,
    _ nameLength: Int32,
    genericContext: UnsafeRawPointer?,
    genericArguments: UnsafeRawPointer?
) -> Any.Type?

@_silgen_name("swift_getTypeContextDescriptor")
public func _swift_getTypeContextDescriptor(
    _ metadata: UnsafeRawPointer?
) -> UnsafeRawPointer?

@_silgen_name("swift_conformsToProtocol")
public func _swift_conformsToProtocol(
    _ type: UnsafeRawPointer,
    _ descriptor: UnsafeRawPointer
) -> UnsafeRawPointer?

public func _swift_getSize(
    of type: Any.Type
) -> Int {
    func project<T>(_: T.Type) -> Int {
        MemoryLayout<T>.size
    }
    
    return _openExistential(type, do: project)
}

public func _swift_demangle(
    mangledName: String
) -> String? {
    return mangledName.utf8CString.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<CChar>) -> String? in
        let demangled = _stdlib_demangleImpl(
            mangledName: buffer.baseAddress as UnsafePointer<CChar>?,
            mangledNameLength: UInt(buffer.count - 1),
            outputBuffer: nil,
            outputBufferSize: nil,
            flags: UInt32(0)
        )
        
        guard let demangled else {
            return nil
        }
        
        let result = String(utf8String: demangled)
        
        free(demangled)
        
        return result
    }
    
}

public func _stdlib_demangleName(
    _ mangled: String
) -> String {
    guard let result = _swift_demangle(mangledName: mangled) else {
        debugPrint("Failed to demangle type: \(mangled)")
        
        return mangled
    }
    
    return result
}

package func _swift_getAllKeyPaths<T>(
    ofType _type: T.Type
) -> [Int: (String, PartialKeyPath<T>)] {
    var membersToKeyPaths = [Int: (String, PartialKeyPath<T>)]()
    var options: _SwiftRuntimeEachFieldOptions = swift_isClassType(T.self) ? [.ignoreUnknown, .classType] : [.ignoreUnknown]
    
    _ = _forEachFieldWithKeyPath(
        of: T.self,
        options: &options
    ) { name, keypath in
        membersToKeyPaths[membersToKeyPaths.count] = (String(cString: name),  keypath as PartialKeyPath)
        
        return true
    }
    
    return membersToKeyPaths
}

// MARK: - Auxiliary

public protocol _swift_RelativePointerProtocol {
    associatedtype Pointee
    
    var offset: Int32 { get }
    
    func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer
    func pointee(from ptr: UnsafeRawPointer) -> Pointee?
}

@frozen
public struct _SwiftRuntimeTypeFieldReflectionMetadata: CustomStringConvertible {
    public typealias Deallocate = @convention(c) (UnsafePointer<CChar>?) -> Void
    
    public let name: UnsafePointer<CChar>? = nil
    public let dealloc: Deallocate? = nil
    public let isStrong: Bool = false
    public let isVar: Bool = false
    
    public init() {
        
    }
    
    public var description: String {
        guard let name else {
            return "<unnamed field>"
        }
        
        return String(validatingUTF8: name) ?? "<error>"
    }
}

public struct _SwiftRuntimeEachFieldOptions: OptionSet {
    ///
    /// Require the top-level type to be a class.
    ///
    /// If this is not set, the top-level type is required to be a struct or
    /// tuple.
    ///
    public static var classType = Self(rawValue: 1 << 0)
    
    ///
    /// Ignore fields that can't be introspected.
    ///
    /// If not set, the presence of things that can't be introspected causes
    /// the function to immediately return `false`.
    ///
    public static var ignoreUnknown = Self(rawValue: 1 << 1)
    
    public var rawValue: UInt32
    
    @_transparent
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public struct _swift_SignedPointer<Pointee> {
    public var base: UnsafeRawPointer
    
    public var signed: UnsafeRawPointer {
        base
    }
}

@frozen
public struct _swift_RelativeDirectPointer<Pointee>: _swift_RelativePointerProtocol {
    public var offset: Int32
    
    @_transparent
    public init(offset: Int32) {
        self.offset = offset
    }
    
    @_transparent
    public func address(
        from pointer: UnsafeRawPointer
    ) -> UnsafeRawPointer {
        return pointer + UnsafeRawPointer.Stride(self.offset)
    }
    
    @_transparent
    public func pointee(
        from pointer: UnsafeRawPointer
    ) -> Pointee? {
        if offset == 0 {
            return nil
        }
        
        return address(from: pointer).load(as: Pointee.self)
    }
}

extension UnsafeRawPointer {
    public func _swift_relativeDirectAddress<T>(as type: T.Type) -> UnsafeRawPointer {
        let relativePointer = _swift_RelativeDirectPointer<T>(
            offset: load(as: Int32.self)
        )
        return relativePointer.address(from: self)
    }
}

@frozen
public struct _swift_RelativeIndirectablePointer<Pointee> {
    public var offset: Int32
    
    @_transparent
    public init(offset: Int32) {
        self.offset = offset
    }
    
    @_transparent
    public func address(from pointer: UnsafeRawPointer) -> UnsafeRawPointer {
        assert(unsafeBitCast(pointer, to: Optional<UnsafeRawPointer>.self) != nil)
        
        let dest = pointer + Int(self.offset & ~1)
        
        // If the low bit is set, then this is an indirect address. Otherwise,
        // it's direct.
        if Int(offset) & 1 == 1 {
            return dest.load(as: UnsafeRawPointer.self)
        } else {
            return dest
        }
    }
}

// MARK: - Error Handling

public struct SwiftFieldNotFoundError: Error, CustomStringConvertible {
    public var key: String
    public var instance: Any.Type
    
    public var description: String {
        "\(key) was not found on instance type \(instance)"
    }
    
    public init(key: String, instance: Any.Type) {
        self.key = key
        self.instance = instance
    }
}

public struct _SwiftFieldTypeMismatchError: Error, CustomStringConvertible {
    public var key: String
    public var expected: Any.Type
    public var received: Any.Type
    public var instance: Any.Type
    
    public init(
        key: String,
        expected: Any.Type,
        received: Any.Type,
        instance: Any.Type
    ) {
        self.key = key
        self.expected = expected
        self.received = received
        self.instance = instance
    }
    
    public var description: String {
        "Expected type of \(expected) for key \(key) but recieved \(received) on instance type \(instance)"
    }
}
