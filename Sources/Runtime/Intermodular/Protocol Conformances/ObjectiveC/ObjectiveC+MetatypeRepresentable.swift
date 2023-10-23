//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCTypeEncoding: MetatypeRepresentable {
    public typealias OpaqueValue = Any.Type
    
    public func toMetatype() -> Any.Type {
        return ObjCTypeCoder.decode(self)
    }
    
    public init?(metatype type: Any.Type) {
        guard let value = ObjCTypeCoder.encode(type) else {
            return nil
        }
        
        self = value
    }
}

extension ObjCClass: NominalTypeMetadata_Type {
    public var isSwiftObject: Bool {
        final class _DummyClass { }
        
        return base == class_getSuperclass(_DummyClass.self)
    }
    
    @_transparent
    public var base: Any.Type {
        value
    }

    public var mangledName: String {
        return name
    }
    
    public var fields: [NominalTypeMetadata.Field] {
        guard !isSwiftObject else {
            return []
        }
        
        return instanceVariables.map {
            .init(
                name: $0.name,
                type: .init($0.typeEncoding.toMetatype()),
                offset: $0.offset
            )
        }
    }
    
    public init?(_ base: Any.Type) {
        guard let base = base as? AnyClass else {
            return nil
        }
        
        self.init(base)
    }
}
