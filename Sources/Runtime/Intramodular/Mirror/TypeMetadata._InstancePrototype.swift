//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    /// A prototype instance of a Swift type.
    public struct _InstancePrototype<InstanceType> {
        public let type: TypeMetadata
        public let instance: InstanceMirror<InstanceType>
        
        fileprivate init(
            type: TypeMetadata,
            instance: InstanceMirror<InstanceType>
        ) {
            assert(!(type.base is (any PropertyWrapper).Type))
            
            self.type = type
            self.instance = instance
        }
    }
}

extension TypeMetadata._InstancePrototype {
    public struct Field {
        public let key: AnyCodingKey
        public let rawValue: Any
        public let rawValueType: TypeMetadata
        public let propertyWrapperType: TypeMetadata?
        public let propertyWrapperMirror: InstanceMirror<any PropertyWrapper>?
        public let unwrappedValueType: TypeMetadata
        
        init(
            field: Runtime.InstanceMirror<InstanceType>.Field,
            in container: Runtime.InstanceMirror<InstanceType>
        ) throws {
            let rawValueType: Any.Type = field.rawValueTypeMetadata.base
            
            self.rawValue = field.rawValue
            self.rawValueType = TypeMetadata(rawValueType)
            
            if let propertyWrapperType = rawValueType as? any PropertyWrapper.Type {
                let propertyWrapper: any PropertyWrapper = try cast(field.rawValue)
                
                assert(field.key.stringValue.hasPrefix("_"))
                
                self.key = AnyCodingKey(stringValue: String(field.key.stringValue.dropFirst()))
                self.propertyWrapperType = TypeMetadata(propertyWrapperType)
                self.propertyWrapperMirror = try InstanceMirror<any PropertyWrapper>(reflecting: propertyWrapper)
            } else {
                self.key = field.key
                self.propertyWrapperType = nil
                self.propertyWrapperMirror = nil
            }
             
            let unwrappedValueType: Any.Type = try propertyWrapperMirror.map({ try cast(Swift.type(of: $0.subject), to: (any PropertyWrapper.Type).self)._opaque_WrappedValue }) ?? rawValueType
            
            self.unwrappedValueType = TypeMetadata(_getUnwrappedType(from: unwrappedValueType))
            
            if self.propertyWrapperType == nil {
                if rawValueType != Any.self {
                    assert(self.unwrappedValueType.base != Any.self)
                }
            }
        }
    }
    
    public subscript(
        field key: AnyCodingKey
    ) -> TypeMetadata._InstancePrototype<InstanceType>.Field {
        get throws {
            let field: InstanceMirror<InstanceType>.Field = try self.instance[field: key]
            
            return try TypeMetadata._InstancePrototype.Field(field: field, in: self.instance)
        }
    }
}

extension TypeMetadata._InstancePrototype {
    public init<T>(
        reflecting type: T.Type
    ) throws {
        let placeholder = try cast(_generatePlaceholder(ofType: type), to: InstanceType.self)
        
        self.init(
            type: TypeMetadata(type),
            instance: try InstanceMirror<InstanceType>(reflecting: placeholder)
        )
    }
}
