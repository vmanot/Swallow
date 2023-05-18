//
// Copyright (c) Vatsal Manot
//

import Swallow

extension ObjCClass {
    public struct UnderlyingStructure: Trivial, @unchecked Sendable {
        public let metaClass: ObjCClass?
        public let superclass: ObjCClass?
        public let cacheData: (UnsafeRawPointer?, UnsafeRawPointer?)
        public let data: UnsafeRawPointer?
        public let flags: UInt32
        public let instanceAddressPoint: UInt32
        public let instanceSize: UInt32
        public let instanceAlignMask: UInt16
        public let reserved: UInt16
        public let classSize: UInt32
        public let classAddressPoint: UInt32
        public let description: NullTerminatedUTF8String?
        public let ivarDestroyer: (@convention(c) (AnyObject) -> Void)?
        
        public init(_ value: AnyClass) {
            self = unsafeBitCast(value, to: UnsafePointer<UnderlyingStructure>.self).pointee
        }
    }
}

// MARK: - Helpers

extension ObjCClass: MutableRawRepresentable {
    public typealias RawValue = UnderlyingStructure
    
    public var rawValue: RawValue {
        get {
            return .init(value)
        }

        nonmutating set {
            unsafeBitCast(value, to: UnsafeMutablePointer<UnderlyingStructure>.self).pointee = newValue
        }
    }
    
    public init(rawValue: RawValue) {
        self = unsafeBitCast(UnsafePointer.allocate(initializingTo: rawValue))
    }
}
