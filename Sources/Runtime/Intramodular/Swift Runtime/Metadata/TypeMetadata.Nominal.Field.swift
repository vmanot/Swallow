//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata.Nominal {
    public struct Field: CustomDebugStringConvertible, CustomStringConvertible, Hashable, Named {
        public let name: String
        public let type: TypeMetadata
        public let offset: Int
        
        public var key: AnyCodingKey {
            .init(stringValue: name)
        }
        
        public init(name: String, type: TypeMetadata, offset: Int) {
            self.name = name
            self.type = type
            self.offset = offset
        }
    }
}

extension TypeMetadata.Nominal.Field {
    public init(objCInstanceVariable: ObjCInstanceVariable) {
        self.name = objCInstanceVariable.name
        self.type = .init(objCInstanceVariable.typeEncoding.toMetatype())
        self.offset = objCInstanceVariable.offset
    }
}
