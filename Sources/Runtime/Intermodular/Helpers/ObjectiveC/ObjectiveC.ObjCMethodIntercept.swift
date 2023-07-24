//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public class ObjCMethodIntercept: Hashable, ReferenceType {
    weak var object: (NSObjectProtocol & ObjCObject)?
    let selector: ObjCSelector

    fileprivate init(object: NSObjectProtocol & ObjCObject, selector: ObjCSelector) {
        self.object = object
        self.selector = selector
    }

    public func invalidate() {

    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: ObjCMethodIntercept, rhs: ObjCMethodIntercept) -> Bool {
        lhs === rhs
    }
}

public final class ObjCMethodSendIntercept: ObjCMethodIntercept {
    public typealias Body = (_ payload: ObjCMethodInvocation.Payload) -> ()

    fileprivate let body: Body

    fileprivate init(object: NSObjectProtocol & ObjCObject, selector: ObjCSelector, _ body: @escaping Body) {
        self.body = body

        super.init(object: object, selector: selector)

        objc_sync(object) {
            object.methodSendIntercepts[selector, default: .init()].append(self)
        }
    }

    public func consume(payload: ObjCMethodInvocation.Payload) {
        body(payload)
    }

    public override func invalidate() {
        guard let object else {
            return
        }
        
        objc_sync(object) {
            object.methodSendIntercepts[selector]?.remove(self)
        }
    }
}

public final class ObjCMethodInvocationIntercept: ObjCMethodIntercept {
    public typealias Body = (_ payload: ObjCMethodInvocation.Payload, _ returnValue: AnyObjCCodable) -> ()

    fileprivate let body: Body

    fileprivate init(object: NSObjectProtocol & ObjCObject, selector: ObjCSelector, _ body: @escaping Body) {
        self.body = body

        super.init(object: object, selector: selector)

        objc_sync(object) {
            object.methodInvocationIntercepts[selector, default: .init()].append(self)
        }
    }

    public func consume(payload: ObjCMethodInvocation.Payload, returnValue: AnyObjCCodable) {
        body(payload, returnValue)
    }

    public override func invalidate() {
        guard let object else {
            return
        }
        
        objc_sync(object) {
            object.methodInvocationIntercepts[selector]?.remove(self)
        }
    }
}

// MARK: - Helpers

private let isReadyForInterceptionKey = ObjCAssociationKey<Bool>()
private let methodSendInterceptsKey = ObjCAssociationKey<[ObjCSelector: Set<ObjCMethodSendIntercept>]>()
private let methodInvocationInterceptsKey = ObjCAssociationKey<[ObjCSelector: Set<ObjCMethodInvocationIntercept>]>()

extension ObjCClass {
    func ensureIsPreparedForInterception(_ selector: ObjCSelector) throws {
        guard !isIntercepted(selector: selector) else {
            return
        }

        try prepareForImplementationVirtualizationIfNecessary()

        try replaceMethodIfNecessary(
            named: selector,
            with: .init { invocation in
                invocation.selector = ObjCSelector(invocation.selector)
                    .taggedAsIntercepted()
                    .value
                invocation.invoke()
            },
            preservingTo: selector.taggedAsIntercepted()
        )
    }
}

extension ObjCObject where Self: NSObjectProtocol {
    var methodSendIntercepts: [ObjCSelector: Set<ObjCMethodSendIntercept>] {
        get {
            return self[methodSendInterceptsKey] ?? [:]
        } set {
            self[methodSendInterceptsKey] = newValue
        }
    }

    var methodInvocationIntercepts: [ObjCSelector: Set<ObjCMethodInvocationIntercept>] {
        get {
            return self[methodInvocationInterceptsKey] ?? [:]
        } set {
            self[methodInvocationInterceptsKey] = newValue
        }
    }
}

extension ObjCObject where Self: NSObjectProtocol {
    public func interceptSend(for selector: ObjCSelector, _ body: @escaping ObjCMethodSendIntercept.Body) throws -> ObjCMethodSendIntercept {
        try objCClass.ensureIsPreparedForInterception(selector)

        return .init(object: self, selector: selector, body)
    }

    public func interceptSend(for selector: Selector, _ body: @escaping ObjCMethodSendIntercept.Body) throws -> ObjCMethodSendIntercept {
        return try interceptSend(for: .init(selector), body)
    }
}

extension ObjCObject where Self: NSObjectProtocol {
    public func interceptInvocation(of selector: ObjCSelector, _ body: @escaping ObjCMethodInvocationIntercept.Body) throws -> ObjCMethodInvocationIntercept {
        try objCClass.ensureIsPreparedForInterception(selector)

        return .init(object: self, selector: selector, body)
    }

    public func interceptInvocation(of selector: Selector, _ body: @escaping ObjCMethodInvocationIntercept.Body) throws -> ObjCMethodInvocationIntercept {
        return try interceptInvocation(of: .init(selector), body)
    }
}

extension ObjCSelector {
    private static let interceptPrefix = "com_vmanot_Runtime_intercepted_"

    func taggedAsIntercepted() -> ObjCSelector {
        let result = ObjCSelector(name: ObjCSelector.interceptPrefix + name)
        result.register()
        return result
    }
}
