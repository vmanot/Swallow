//
// Copyright (c) Vatsal Manot
//

import Swift

@_alwaysEmitConformanceMetadata
public protocol _StaticSwift_IsPlaceholderedVariantOfGenericType {
    associatedtype _StaticSwift_GenericTypeParameterName: _StaticSwift.GenericTypeParameterNameProtocol = Never
}

@_alwaysEmitConformanceMetadata
public protocol _StaticSwift_HasPlaceholderedVariantOfGenericSelf {
    static var _StaticSwift_replacingGenericTypeParametersWithPlaceholders: any _StaticSwift_IsPlaceholderedVariantOfGenericType.Type { get }
}

extension _StaticSwift {
    @_alwaysEmitConformanceMetadata
    public protocol GenericTypeParameterNameProtocol: Hashable {
        
    }
    
    public struct GenericTypeParameterNameOfType: CustomStringConvertible, Hashable {
        @_HashableExistential
        public var type: any _StaticSwift_IsPlaceholderedVariantOfGenericType.Type
        @_HashableExistential
        public var parameter: (any _StaticSwift.GenericTypeParameterNameProtocol)?
        
        public var description: String {
            String(describing: type) + (parameter.map({ " " + String(describing: $0) }) ?? "")
        }
        
        public init<T: _StaticSwift_IsPlaceholderedVariantOfGenericType>(
            type: T.Type,
            parameter: T._StaticSwift_GenericTypeParameterName?
        ) {
            self.type = type
            self.parameter = parameter
        }
    }
}

extension Never: _StaticSwift.GenericTypeParameterNameProtocol {
    
}
