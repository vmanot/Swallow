//
// Copyright (c) Vatsal Manot
//

import Foundation
import ObjectiveC
import Swallow

public struct ObjCMethodInvocation: CustomDebugStringConvertible {
    public var method: ObjCMethod
    public var payload: Payload
    
    public init(method: ObjCMethod, payload: Payload) {
        self.method = method
        self.payload = payload
    }
}

extension ObjCMethodInvocation {
    public func toNSInvocation() -> NSInvocationProtocol {
        let invocation = method.signature.toEmptyNSInvocation()
        let buffer = payload.map({ $0.encodeObjCValueToRawBuffer() })
        
        buffer
            .enumerated()
            .forEach({ invocation.setArgument($1, atIndex: $0) })
        
        invocation.target = payload.target
        
        payload
            .enumerated()
            .forEach {
                $1.deinitializeRawObjCValueBuffer(buffer[$0])
                buffer[$0].deallocate()
            }
        
        return invocation
    }
    
    public func execute() throws -> AnyObjCCodable {
        let invocation = toNSInvocation()
        
        invocation.invoke()
        
        return try AnyObjCCodable(_returnValueFromInvocation: invocation)
    }
}

// MARK: - Helpers

extension ObjCObject {
    public func invokeSelector(_ selector: ObjCSelector, with arguments: [AnyObjCCodable]) throws -> AnyObjCCodable {
        let method = try objCClass.method(for: selector)
        let payload = ObjCMethodInvocation.Payload(
            target: self,
            selector: .init(rawValue: method.name),
            arguments: arguments
        )
        let invocation = ObjCMethodInvocation(method: method, payload: payload)
        
        return try invocation.execute()
    }
    
    public func invokeSelector(
        _ selector: ObjCSelector,
        with argument: AnyObjCCodable
    ) throws -> AnyObjCCodable {
        return try invokeSelector(selector, with: [argument])
    }
    
    public func invokeMethodNamed(
        _ name: String,
        with arguments: [AnyObjCCodable]
    ) throws -> AnyObjCCodable {
        return try invokeSelector(.init(name: name), with: arguments)
    }
    
    public func invokeMethodNamed(
        _ name: String,
        with argument: AnyObjCCodable
    ) throws -> AnyObjCCodable {
        return try invokeMethodNamed(name, with: [argument])
    }
}
