//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
@_transparent
public func withUnsafeInstancePointer<InstanceType, Result>(
    _ instance: InstanceType,
    _ body: (UnsafeRawPointer) throws -> Result
) throws -> Result {
    if swift_isClassType(InstanceType.self) {
        return try withUnsafePointer(to: instance) {
            try $0.withMemoryRebound(to: UnsafeRawPointer.self, capacity: 1) {
                try body($0.pointee)
            }
        }
    } else {
        return try withUnsafePointer(to: instance) {
            let ptr = UnsafeRawPointer($0)
            
            return try body(ptr)
        }
    }
}

@_spi(Internal)
@_transparent
public func withUnsafeMutableInstancePointer<InstanceType, Result>(
    _ instance: inout InstanceType,
    _ body: (UnsafeMutableRawPointer) throws -> Result
) throws -> Result {
    if swift_isClassType(InstanceType.self) {
        return try withUnsafeMutablePointer(to: &instance) {
            try $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                try body($0.pointee)
            }
        }
    } else {
        return try withUnsafeMutablePointer(to: &instance) {
            let ptr = UnsafeMutableRawPointer(mutating: $0)
            
            return try body(ptr)
        }
    }
}
