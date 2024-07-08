//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public final class ObjCVirtualMethodImplementation: Hashable, ReferenceType {
    public typealias Value = ((NSInvocationProtocol) -> Void)
    
    private let value: Value
        
    public init(_ value: @escaping Value) {
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public func invoke(for invocation: NSInvocationProtocol) {
        value(invocation)
    }
    
    public static func == (lhs: ObjCVirtualMethodImplementation, rhs: ObjCVirtualMethodImplementation) -> Bool {
        lhs === rhs
    }
}

// MARK: - Applicative Implementation -

extension ObjCClass {
    private static let virtualMethodImplementationsKey = ObjCAssociationKey<[ObjCSelector: ObjCVirtualMethodImplementation]>()
    
    var virtualMethodImplementations: [ObjCSelector: ObjCVirtualMethodImplementation] {
        get {
            return self[ObjCClass.virtualMethodImplementationsKey, default: [:]]
        } nonmutating set {
            self[ObjCClass.virtualMethodImplementationsKey] = newValue
        }
    }
    
    func isVirtual(selector: ObjCSelector) -> Bool {
        return virtualMethodImplementations.contains(key: selector)
    }
    
    func isIntercepted(selector: ObjCSelector) -> Bool {
        return responds(to: selector.taggedAsIntercepted())
    }
}

extension ObjCObject where Self: NSObjectProtocol {
    func hasRegisteredIntercept(for selector: ObjCSelector) -> Bool {
        if methodInvocationIntercepts.contains(key: selector) {
            return true
        } else if methodSendIntercepts.contains(key: selector) {
            return true
        } else {
            return false
        }
    }
    
    private func processVirtual(invocation: NSInvocationProtocol) throws {
        let selector = ObjCSelector(invocation.selector)
        
        func invoke() {
            invocation.invoke(
                using: objCClass.virtualMethodImplementations[selector]!
            )
        }
        
        if hasRegisteredIntercept(for: selector) {
            let sendIntercepts = methodSendIntercepts[selector]
            let invocationIntercepts = methodInvocationIntercepts[selector]
            let payload = try ObjCMethodInvocation(nsInvocation: invocation).payload
            
            sendIntercepts?.forEach({ $0.consume(payload: payload) })
            
            invoke()
            
            try invocationIntercepts.map {
                let returnValue = try AnyObjCCodable(_returnValueFromInvocation: invocation)
             
                $0.forEach {
                    $0.consume(payload: payload, returnValue: returnValue)
                }
            }
        } else {
            invoke()
        }
    }
    
    fileprivate func newForwardInvocation(_ invocation: NSInvocationProtocol) throws {
        let selector = ObjCSelector(invocation.selector)
        
        if objCClass.isVirtual(selector: selector) {
            try processVirtual(invocation: invocation)
        } else {
            _ = try! invokeSelector(
                .preserved_forwardInvocation,
                with: .init(invocation)
            )
        }
    }
}

extension ObjCClass {
    func prepareForImplementationVirtualizationIfNecessary() throws {
        guard !responds(to: .preserved_forwardInvocation) else {
            return
        }
        
        let newForwardInvocationImpl: (@convention(c) (NSObjectProtocol & ObjCObject, Selector, NSInvocationProtocol) -> Void) = {
            try! $0.newForwardInvocation($2)
        }
        
        try replace(
            methodNamed: .forwardInvocation,
            with: unsafeBitCast(newForwardInvocationImpl, to: ObjCImplementation.self),
            preservingTo: .preserved_forwardInvocation
        )
    }
    
    public func isRegistered(_ implementation: ObjCVirtualMethodImplementation, for selector: ObjCSelector) -> Bool {
        return virtualMethodImplementations.contains(key: selector)
    }
    
    public func register(_ implementation: ObjCVirtualMethodImplementation, for selector: ObjCSelector) throws {
        try prepareForImplementationVirtualizationIfNecessary()
        
        virtualMethodImplementations[selector] = implementation
    }
}

extension ObjCClass {
    public func addVirtualImplementation(_ implementation: ObjCVirtualMethodImplementation, for selector: ObjCSelector, signature: ObjCMethodSignature) throws {
        try register(implementation, for: selector)
        
        let implementation = signature.isSpecialStructReturn
            ? ObjCRuntime._objc_msgForward_stret
            : ObjCRuntime._objc_msgForward
        
        try addMethod(
            named: selector,
            implementation: implementation,
            signature: signature
        )
    }
    
    public func addVirtualImplementationIfNecessary(_ implementation: ObjCVirtualMethodImplementation, for selector: ObjCSelector, signature: ObjCMethodSignature) throws {
        guard !isRegistered(implementation, for: selector) else {
            return
        }
        
        try addVirtualImplementation(implementation, for: selector, signature: signature)
    }
    
    public func addVirtualImplementationIfNecessary(_ implementation: ObjCVirtualMethodImplementation, forInherited selector: ObjCSelector) throws {
        guard !isRegistered(implementation, for: selector) else {
            return
        }
        
        try addVirtualImplementation(
            implementation,
            for: selector,
            signature: try inheritedMethodDescription(for: selector).signature
        )
    }
}

extension ObjCClass {
    public func replaceMethod(
        named selector: ObjCSelector,
        with implementation: ObjCVirtualMethodImplementation,
        preservingTo otherSelector: ObjCSelector
    ) throws {
        try register(implementation, for: selector)
        
        let signature = try method(for: selector).signature
        let implementation = signature.isSpecialStructReturn
            ? ObjCRuntime._objc_msgForward_stret
            : ObjCRuntime._objc_msgForward
        
        try replace(methodNamed: selector,
                    with: implementation,
                    preservingTo: otherSelector)
    }
    
    public func replaceMethodIfNecessary(
        named selector: ObjCSelector,
        with implementation: ObjCVirtualMethodImplementation,
        preservingTo otherSelector: ObjCSelector
    ) throws {
        guard !isRegistered(implementation, for: selector) else {
            return
        }
        
        try replaceMethod(named: selector, with: implementation, preservingTo: otherSelector)
    }
}
