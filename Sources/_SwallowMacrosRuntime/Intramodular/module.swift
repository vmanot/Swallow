//
// Copyright (c) Vatsal Manot
//

@_implementationOnly import Diagnostics
import Foundation
import Swallow

@objc(_Swallow_RuntimeTypeDiscovery) open class _RuntimeTypeDiscovery: NSObject {
    open class var type: Any.Type {
        assertionFailure()
        
        return Never.self
    }
}

@objc open class _RuntimeConversion: NSObject {
    open class var type: Any.Type {
        assertionFailure()
        
        return Never.self
    }
}

public protocol _NonGenericRuntimeConversionProtocol {
    associatedtype Source
    associatedtype Destination
    
    func __convert(_ source: Source) throws -> Destination
}

public protocol _PerformOnce: Initiable {
    init()
    
    func perform()
}
