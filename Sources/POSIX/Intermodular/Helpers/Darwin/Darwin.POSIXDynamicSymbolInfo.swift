//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

public struct POSIXDynamicSymbolInfo: Initiable {
    public typealias Value = Dl_info
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init() {
        self.value = .init()
    }
    
    public init<Address: RawPointer>(_ address: Address)  {
        self.init()
        
        dladdr(UnsafeRawPointer(address), &value)
    }
}

extension POSIXDynamicSymbolInfo {
    public var baseAddressOfSharedObject: UnsafeMutableRawPointer? {
        return value.dli_fbase
    }
    
    public var pathNameOfSharedObject: NullTerminatedUTF8String? {
        return value.dli_fname.map(NullTerminatedUTF8String.init)
    }
    
    public var nameOfNearestSymbol: NullTerminatedUTF8String? {
        return value.dli_sname.map(NullTerminatedUTF8String.init)
    }
    
    public var nearestSymbol: POSIXDynamicSymbolInfo? {
        return value.dli_saddr.map(POSIXDynamicSymbolInfo.init)
    }
    
    public var currentImage: POSIXDynamicSymbolInfo? {
        var info = Dl_info(dli_fname: nil, dli_fbase: nil, dli_sname: nil, dli_saddr: nil)
        
        dladdr(Thread.callStackReturnAddresses[1].pointerValue, &info)
        
        return .init(info)
    }
}
