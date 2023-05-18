//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCMethod {
    public struct UnderlyingStructure {
        public let selector: ObjCSelector
        public let signature: NullTerminatedUTF8String
        public let implementation: ObjCImplementation
        
        public init(selector: ObjCSelector, signature: String, implementation: ObjCImplementation) {
            self.selector = selector
            self.signature = signature.nullTerminatedUTF8String()
            self.implementation = implementation
        }
    }
}

extension ObjCMethod: MutableRawRepresentable {
    public typealias RawValue = UnderlyingStructure
    
    public var rawValue: RawValue {
        get {
            return UnsafePointer(value).pointee
        }
        
        nonmutating set {
            UnsafeMutablePointer(value).pointee = newValue
        }
    }
    
    public init(rawValue: RawValue) {
        self.init(.init(UnsafePointer.allocate(initializingTo: rawValue)))
    }
}
