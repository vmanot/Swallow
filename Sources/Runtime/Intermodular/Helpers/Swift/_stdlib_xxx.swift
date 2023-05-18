//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

@_silgen_name("swift_demangle") private func _stdlib_demangleImpl(_ mangledName: UnsafePointer<CChar>?, mangledNameLength: Int, outputBuffer: UnsafeMutablePointer<UInt8>?, outputBufferSize: UnsafeMutablePointer<UInt>?, flags: UInt32) -> UnsafeMutablePointer<CChar>?

public func _stdlib_demangleName(_ mangled: String) -> String {
    return mangled.utf8CString.withUnsafeBufferPointer {
        return _stdlib_demangleImpl($0.baseAddress, mangledNameLength: Int($0.count - 1), outputBuffer: nil, outputBufferSize: nil, flags: 0).map({ String(utf8String: $0, deallocate: true) }) ?? mangled
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
public func _swift_getTypeContextDescriptor(_ metadata: UnsafeRawPointer?) -> UnsafeRawPointer?
