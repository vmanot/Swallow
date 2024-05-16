//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCProtocol: CustomStringConvertible, ExpressibleByStringLiteral, Wrapper {
    public typealias Value = Protocol
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Conformances

extension ObjCProtocol: CaseIterable {
    public static var allCases: AnyRandomAccessCollection<ObjCProtocol> {
        return objc_realizeListAllocator({ objc_copyProtocolList($0) })
    }
}

extension ObjCProtocol {
    public func insert(
        instanceMethod method: ObjCMethodDescription
    ) {
        protocol_addMethodDescription(value, Selector(method.name), method.signature.rawValue, true, true)
    }
    
    public func insert(
        classMethod method: ObjCMethodDescription
    ) {
        protocol_addMethodDescription(value, Selector(method.name), method.signature.rawValue, true, false)
    }
    
    public func insert(
        optionalInstanceMethod method: ObjCMethodDescription
    ) {
        protocol_addMethodDescription(value, Selector(method.name), method.signature.rawValue, false, true)
    }
    
    public func insert(
        optionalClassMethod method: ObjCMethodDescription
    ) {
        protocol_addMethodDescription(value, Selector(method.name), method.signature.rawValue, false, false)
    }
    
    public func insert(
        adoptedProtocol `protocol`: ObjCProtocol
    ) {
        protocol_addProtocol(value, `protocol`.value)
    }
    
    public func insert(
        instanceProperty property: ObjCProperty
    ) {
        let attributes = Array(property.attributeKeyValuePairs.map(keyPath: \.value))
        
        protocol_addProperty(value, property.name, attributes, .init(attributes.count), true, true)
    }
    
    public func insert(
        classProperty property: ObjCProperty
    ) {
        let attributes = Array(property.attributeKeyValuePairs.map(keyPath: \.value))
        
        protocol_addProperty(value, property.name, attributes, .init(attributes.count), true, false)
    }
    
    public func insert(
        optionalInstanceProperty property: ObjCProperty
    ) {
        let attributes = Array(property.attributeKeyValuePairs.map(keyPath: \.value))
        
        protocol_addProperty(value, property.name, attributes, .init(attributes.count), false, true)
    }
    
    public func insert(
        optionalClassProperty property: ObjCProperty
    ) {
        let attributes = Array(property.attributeKeyValuePairs.map(keyPath: \.value))
        
        protocol_addProperty(value, property.name, attributes, .init(attributes.count), false, false)
    }
}

extension ObjCProtocol: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value === rhs.value
    }
}

extension ObjCProtocol: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension ObjCProtocol: Named, NameInitiable {
    public var name: String {
        return .init(utf8String: protocol_getName(value))
    }
    
    public init(name: String) {
        if let value = objc_getProtocol(name) {
            self.init(value)
        } else {
            self.init(objc_allocateProtocol(name)!)
            
            register()
        }
    }
}

extension ObjCProtocol: ObjCRegistree {
    public func register() {
        objc_registerProtocol(value)
    }
}

extension ObjCProtocol {
    public var instanceMethods: AnyRandomAccessCollection<ObjCMethodDescription> {
        return protocol_realizeListAllocator(value, with: { protocol_copyMethodDescriptionList($0, $1, $2, $3) }, (true, true)).filterOutInvalids()
    }
    
    public var optionalInstanceMethods: AnyRandomAccessCollection<ObjCMethodDescription> {
        return protocol_realizeListAllocator(value, with: { protocol_copyMethodDescriptionList($0, $1, $2, $3) }, (false, true)).filterOutInvalids()
    }
    
    public var allInstanceMethods: AnyRandomAccessCollection<ObjCMethodDescription> {
        Array(instanceMethods)
            .appending(contentsOf: optionalInstanceMethods)
            .eraseToAnyRandomAccessCollection()
    }
    
    public var classMethods: AnyRandomAccessCollection<ObjCMethodDescription> {
        return protocol_realizeListAllocator(value, with: { protocol_copyMethodDescriptionList($0, $1, $2, $3) }, (true, false)).filterOutInvalids()
    }
    
    public var optionalClassMethods: AnyRandomAccessCollection<ObjCMethodDescription> {
        return protocol_realizeListAllocator(value, with: { protocol_copyMethodDescriptionList($0, $1, $2, $3) }, (false, false)).filterOutInvalids()
    }
    
    public var instanceProperties: AnyRandomAccessCollection<ObjCProperty> {
        return protocol_realizeListAllocator(value, with: { protocol_copyPropertyList2($0, $1, $2, $3) }, (true, true))
    }
    
    public var classProperties: AnyRandomAccessCollection<ObjCProperty> {
        protocol_realizeListAllocator(value, with: { protocol_copyPropertyList2($0, $1, $2, $3) }, (true, false))
    }
    
    public var optionalInstanceProperties: AnyRandomAccessCollection<ObjCProperty> {
        protocol_realizeListAllocator(value, with: { protocol_copyPropertyList2($0, $1, $2, $3) }, (false, true))
    }
    
    public var optionalClassProperties: AnyRandomAccessCollection<ObjCProperty> {
        protocol_realizeListAllocator(value, with: { protocol_copyPropertyList2($0, $1, $2, $3) }, (false, false))
    }
    
    public var allProperties: AnyRandomAccessCollection<ObjCProperty> {
        objc_realizeListAllocator({ protocol_copyPropertyList($0, $1) }, value)
    }
    
    public var adoptedProtocols: AnyRandomAccessCollection<ObjCProtocol> {
        objc_realizeListAllocator({ protocol_copyProtocolList($0, $1) }, value)
    }
}

// MARK: - Helpers

extension ObjCClass {
    public func inheritedMethodDescription(
        for selector: ObjCSelector
    ) throws -> ObjCMethodDescription {
        // Check if the current class responds to the selector
        guard !responds(to: selector) else {
            return try! method(for: selector).getDescription()
        }
        
        // Gather all instance methods from the protocols
        let allInstanceMethods: LazySequence<FlattenSequence<LazyMapSequence<LazySequence<AnyRandomAccessCollection<ObjCProtocol>>.Elements, AnyRandomAccessCollection<ObjCMethodDescription>>>> = protocols
            .lazy
            .flatMap { $0.allInstanceMethods }
        
        // Gather all adopted instance methods from the adopted protocols
        let allAdoptedInstanceMethods: LazySequence<FlattenSequence<LazyMapSequence<LazySequence<FlattenSequence<LazyMapSequence<LazySequence<AnyRandomAccessCollection<ObjCProtocol>>.Elements, AnyRandomAccessCollection<ObjCProtocol>>>>.Elements, AnyRandomAccessCollection<ObjCMethodDescription>>>> = protocols
            .lazy
            .flatMap { $0.adoptedProtocols }
            .flatMap({ $0.allInstanceMethods })
        
        // Find the method description matching the selector in the gathered methods
        let result: ObjCMethodDescription? = nil
        ?? allInstanceMethods.first(where: { $0.selector == selector })
        ?? allAdoptedInstanceMethods.first(where: { $0.selector == selector })
        
        // Unwrap and return the found method description, or throw an error if not found
        return try result.unwrap()
    }
}
