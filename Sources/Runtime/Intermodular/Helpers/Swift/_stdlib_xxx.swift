//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

@_silgen_name("swift_isClassType")
public func swift_isClassType(
    _: Any.Type
) -> Bool

@_silgen_name("swift_reflectionMirror_recursiveCount")
public func swift_reflectionMirror_recursiveCount(
    _: Any.Type
) -> Int

@_silgen_name("swift_reflectionMirror_recursiveChildMetadata")
public func swift_reflectionMirror_recursiveChildMetadata(
    _: Any.Type
    , index: Int
    , fieldMetadata: UnsafeMutablePointer<_SwiftRuntimeTypeFieldReflectionMetadata>
) -> Any.Type

@_silgen_name("swift_reflectionMirror_recursiveChildOffset")
public func swift_reflectionMirror_recursiveChildOffset(
    _: Any.Type,
    index: Int
) -> Int

@_silgen_name("swift_demangle")
private func _stdlib_demangleImpl(
    _ mangledName: UnsafePointer<CChar>?,
    mangledNameLength: Int,
    outputBuffer: UnsafeMutablePointer<UInt8>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
) -> UnsafeMutablePointer<CChar>?

public func _stdlib_demangleName(
    _ mangled: String
) -> String {
    return mangled.utf8CString.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<CChar>) in
        return _stdlib_demangleImpl(
            buffer.baseAddress,
            mangledNameLength: Int(buffer.count - 1),
            outputBuffer: nil,
            outputBufferSize: nil, flags: 0
        )
        .map({ String(utf8String: $0, deallocate: true) }) ?? mangled
    }
}

@_silgen_name("swift_getTypeByMangledNameInContext")
public func _swift_getTypeByMangledNameInContext(
    _ name: UnsafePointer<Int8>,
    _ nameLength: Int32,
    genericContext: UnsafeRawPointer?,
    genericArguments: UnsafeRawPointer?
) -> Any.Type?

@_silgen_name("swift_getTypeContextDescriptor")
public func _swift_getTypeContextDescriptor(
    _ metadata: UnsafeRawPointer?
) -> UnsafeRawPointer?

@_silgen_name("swift_isClassType")
public func _swift_isClassType(
    _ type: Any.Type
) -> Bool

// MARK: - Auxiliary

public struct _SwiftRuntimeTypeFieldReflectionMetadata {
    public typealias Dealloc = @convention(c) (UnsafePointer<CChar>?) -> Void

    let name: UnsafePointer<CChar>? = nil
    let dealloc: Dealloc? = nil
    let isStrong: Bool = false
    let isVar: Bool = false
}
