//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@objc public protocol NSMethodSignatureProtocol {
    var debugDescription: String { get }
    var numberOfArguments: UInt { get }
    var frameLength: Int { get }
    var isOneway: Bool { get }
    var methodReturnType: UnsafePointer<CChar> { get }
    var methodReturnLength: Int { get }
    
    static func signatureWithObjCTypes(_: UnsafePointer<Int8>) -> NSMethodSignatureProtocol
    
    func getArgumentTypeAtIndex(_: UInt) -> UnsafePointer<CChar>
}

let NSMethodSignatureType = unsafeBitCast(ObjCClass(name: "NSMethodSignature"), to: NSMethodSignatureProtocol.Type.self)
