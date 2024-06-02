//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _StaticSwift_CanHavePlaceholderGenericTypeParameters {
    associatedtype _StaticSwift_GenericTypeParameterName: _StaticSwift.GenericTypeParameterNameProtocol = Never
}

public protocol _StaticSwift_HasPlaceholderedGenericTypeParameters {
    static var _StaticSwift_replacingGenericTypeParametersWithPlaceholders: any _StaticSwift_CanHavePlaceholderGenericTypeParameters.Type { get }
}

extension _StaticSwift {
    public protocol GenericTypeParameterNameProtocol: Hashable {
        
    }
    
    public struct GenericTypeParameterNameOfType: CustomStringConvertible, Hashable {
        @_HashableExistential
        public var type: any _StaticSwift_CanHavePlaceholderGenericTypeParameters.Type
        @_HashableExistential
        public var parameter: (any _StaticSwift.GenericTypeParameterNameProtocol)?
        
        public var description: String {
            String(describing: type) + (parameter.map({ " " + String(describing: $0) }) ?? "")
        }
        
        public init<T: _StaticSwift_CanHavePlaceholderGenericTypeParameters>(
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
