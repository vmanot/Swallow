//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCMethod: CustomStringConvertible, Wrapper {
    public typealias Value = Method
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

extension ObjCMethod {
    public init(description: ObjCMethodDescription, implementation: ObjCImplementation) {
        let cls = ObjCClass(name: #function)
        let classAddMethodResult = class_addMethod(
            cls.value,
            description.selector.value,
            implementation.value,
            description.signature.rawValue
        )
        
        try! classAddMethodResult.orThrow()
        self = cls[methodNamed: description.name]!
        cls.dispose()
    }
    
    public func getDescription() -> ObjCMethodDescription {
        return .init(method_getDescription(value).pointee)
    }
}

extension ObjCMethod {
    public var numberOfArguments: Int {
        return method_getNumberOfArguments(value).toInt()
    }
    
    public var argumentTypes: [ObjCTypeEncoding] {
        return (0..<method_getNumberOfArguments(value))
            .lazy
            .map({ method_copyArgumentType(value, $0) })
            .map({ String(utf8String: $0, deallocate: true)! })
            .map({ .init($0) })
    }
    
    public var returnType: ObjCTypeEncoding {
        return .init(.init(utf8String: method_copyReturnType(value), deallocate: true))
    }
    
    public var signature: ObjCMethodSignature {
        return .init(rawValue: String(utf8String: method_getTypeEncoding(value))!)
    }
}

// MARK: - Conformances

extension ObjCMethod: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension ObjCMethod: Named {
    public var name: String {
        return method_getName(value).value
    }
}
