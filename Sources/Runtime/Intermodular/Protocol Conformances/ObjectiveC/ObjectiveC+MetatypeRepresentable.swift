//
// Copyright (c) Vatsal Manot
//

import Foundation
import ObjectiveC
import Swallow

extension ObjCTypeEncoding {
    public typealias OpaqueValue = Any.Type
    
    public func toMetatype() throws -> Any.Type {
        return try ObjCTypeCoder.decode(self)
    }
    
    public init?(metatype type: Any.Type) throws {
        guard let value = try ObjCTypeCoder.encode(type) else {
            return nil
        }
        
        self = value
    }
}

extension ObjCClass: _NominalTypeMetadataType {
    private static func _get_swiftObjectBaseClass() -> AnyClass {
        final class _TestClass { }
        
        let result: AnyClass = class_getSuperclass(_TestClass.self)!
        
        return result
    }
    
    public static private(set) var _swiftObjectBaseClass: ObjCClass = {
        ObjCClass(_get_swiftObjectBaseClass())
    }()
    
    public var isBaseSwiftObject: Bool {
        self == Self._swiftObjectBaseClass
    }
    
    @_transparent
    public var base: Any.Type {
        value
    }
    
    public var mangledName: String {
        return name
    }
    
    public var fields: [NominalTypeMetadata.Field] {
        guard self != ObjCClass._swiftObjectBaseClass else {
            return []
        }
        
        return instanceVariables.compactMap { (variable: ObjCInstanceVariable) -> NominalTypeMetadata.Field? in
            do {
                let className = String(variable.typeEncoding.value.dropPrefixIfPresent("@\"").dropSuffixIfPresent("\""))
                
                let type: TypeMetadata? = NSClassFromString(className).map {
                    TypeMetadata($0)
                }
                
                let field = NominalTypeMetadata.Field(
                    name: variable.name,
                    type: try type ?? TypeMetadata(variable.typeEncoding.toMetatype()),
                    offset: variable.offset
                )
                
                return field
            } catch {
                return nil
            }
        }
    }
    
    public init?(_ base: Any.Type) {
        guard let base = base as? AnyClass else {
            return nil
        }
        
        self.init(base)
    }
}
