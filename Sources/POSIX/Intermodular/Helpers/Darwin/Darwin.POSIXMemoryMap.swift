//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXMemoryMap {
    public typealias BaseAddressPointer = Value.BaseAddressPointer
    public typealias Element = Value.Element
    public typealias Index = Value.Index
    public typealias IndexDistance = Value.Index
    public typealias Iterator = Value.Iterator
    public typealias SubSequence = Value.SubSequence
    public typealias Value = UnsafeRawBufferPointer
    
    public let value: Value
    
    public var baseAddress: BaseAddressPointer? {
        value.baseAddress
    }
    
    public var count: Int {
        value.count
    }
    
    public init(_ value: Value) {
        self.value = value
    }
}

extension POSIXMemoryMap {
    public init(length: IndexDistance, protection: POSIXMemoryMapProtection, accessControl: POSIXMemoryMapAccessControl = .init(), flags: POSIXMemoryMapOtherFlags = .init(), descriptor: POSIXIOResourceDescriptor, offset: Int64 = 0) throws {
        let baseAddress = try Optional(mmap(nil, length, protection.rawValue, POSIXMemoryMapType.file.rawValue ^ accessControl.rawValue ^ flags.rawValue, descriptor.rawValue, offset)).toPOSIXResult().get().immutableRepresentation
        
        self.init(.init(start: baseAddress, count: length))
    }
    
    public init(protection: POSIXMemoryMapProtection, accessControl: POSIXMemoryMapAccessControl = .init(), flags: POSIXMemoryMapOtherFlags = .init(), descriptor: POSIXIOResourceDescriptor, offset: Int64 = 0) throws {
        try self.init(length: numericCast(try descriptor.getFileStatus().size), protection: protection, accessControl: accessControl, flags: flags, descriptor: descriptor, offset: offset)
    }
}

extension POSIXMemoryMap {
    public func synchronize(synchronously: Bool = true, invalidateSharedMaps: Bool = false) throws {
        try msync(try baseAddress.unwrap().mutableRepresentation, count, (synchronously ? MS_SYNC : MS_ASYNC) ^ (invalidateSharedMaps ? MS_INVALIDATE : 0)).throwingAsPOSIXErrorIfNecessary()
    }
    
    public func unmap() throws {
        try munmap(try baseAddress.unwrap().mutableRepresentation, count).throwingAsPOSIXErrorIfNecessary()
    }
}
