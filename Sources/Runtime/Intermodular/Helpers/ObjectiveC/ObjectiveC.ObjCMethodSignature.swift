//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCMethodSignature: Codable, Hashable, RawRepresentable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - Extensions

extension ObjCMethodSignature {
    public var returnType: ObjCTypeEncoding {
        return ObjCTypeEncoding(returnTypeFrom: toNSMethodSignature())
    }
    
    public var isVoidReturn: Bool {
        return returnType == .void
    }
}

extension ObjCMethodSignature {
    var isSpecialStructReturn: Bool {
        return toNSMethodSignature().debugDescription.contains("is special struct return? YES")
    }
    
    public func toNSMethodSignature() -> NSMethodSignatureProtocol {
        return NSMethodSignatureType.signatureWithObjCTypes(rawValue)
    }
    
    public func toEmptyNSInvocation() -> NSInvocationProtocol {
        NSInvocationType.invocationWithMethodSignature(toNSMethodSignature())
    }
}

// MARK: - Conformances

extension ObjCMethodSignature: CustomStringConvertible {
    public var description: String {
        rawValue.description
    }
}
