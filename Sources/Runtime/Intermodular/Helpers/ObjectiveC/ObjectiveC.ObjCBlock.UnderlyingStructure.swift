//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCBlock {
    public struct UnderlyingStructure {
        public let isa: ObjCClass?
        public let flags: Flags
        public let reserved: ByteTuple4
        public let invoker: UnsafeRawPointer?
        public let descriptor: UnsafeMutablePointer<Descriptor>?
    }
}

extension ObjCBlock.UnderlyingStructure {
    public struct Flags: OptionSet {
        public typealias RawValue = CInt
        
        public static let hasCopyDispose = with(rawValue: (1 << 25))
        public static let hasConstructor = with(rawValue: (1 << 26))
        public static let isGlobal = with(rawValue: (1 << 28))
        public static let returnsStructure = with(rawValue: (1 << 29))
        public static let hasSignature = with(rawValue: (1 << 30))
        
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension ObjCBlock.UnderlyingStructure {
    public struct Descriptor {
        public let reserved: CUnsignedLong
        public let size: CUnsignedLong
        public let copyHelper: (@convention(c) (_ from: UnsafeMutableRawPointer, _ to: UnsafeMutableRawPointer) -> Void)!
        public let disposeHelper: (@convention(c) (UnsafeMutableRawPointer) -> Void)!
        public let signature: NullTerminatedUTF8String?
    }
}

extension ObjCBlock: MutableRawValueConvertible {
    public typealias RawValue = UnderlyingStructure
    
    public var rawValue: RawValue {
        get {
            return unsafeBitCast(value, to: UnsafePointer.self).pointee
        }
        
        nonmutating set {
            unsafeBitCast(value, to: UnsafeMutablePointer.self).pointee = newValue
        }
    }
}
