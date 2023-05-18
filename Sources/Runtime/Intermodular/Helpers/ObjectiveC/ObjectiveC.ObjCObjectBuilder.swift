//
// Copyright (c) Vatsal Manot
//

import Foundation
import ObjectiveC
import Swallow

public struct ObjCObjectBuilder<T: AnyObject> {
    public var pseudoHeader: ObjCProtocol
    public var builtClass: ObjCClass
    
    public init(protocol: Protocol) {
        pseudoHeader = .init(`protocol`)
        builtClass = .init(name: UUID().uuidString)
    }
}

extension ObjCObjectBuilder {
    public func build() -> T! {
        return try? cast((builtClass.value as? Initiable.Type)?.init())
    }
}

extension ObjCObjectBuilder {
    public func implement(
        method selector: ObjCSelector,
        _ implementation: ObjCImplementation
    ) throws {
        try pseudoHeader.allInstanceMethods
            .find({ $0.name == selector.rawValue })
            .map({ try builtClass.insert($0, implementation) })
            .unwrap()
    }
    
    public func reimplement(
        method selector: ObjCSelector,
        _ implementation: ObjCImplementation
    ) throws {
        _ = try pseudoHeader.allInstanceMethods
            .find({ $0.name == selector.rawValue })
            .map({ try builtClass.replace($0, with: implementation) })
            .unwrap()
    }
}
