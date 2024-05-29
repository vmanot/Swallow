//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _StaticSwift_GenericTypeParameterNameProtocol: Hashable {
    
}

public protocol _StaticSwift_CanHavePlaceholderGenericTypeParameters {
    associatedtype _StaticSwift_GenericTypeParameterName: _StaticSwift_GenericTypeParameterNameProtocol = Never
}

public protocol _StaticSwift_HasPlaceholderedGenericTypeParameters {
    static var _StaticSwift_replacingGenericTypeParametersWithPlaceholders: any _StaticSwift_CanHavePlaceholderGenericTypeParameters.Type { get }
}

public struct _StaticSwift_GenericTypeParameterNameOfSwiftType: CustomStringConvertible, Hashable {
    @_HashableExistential
    public var type: any _StaticSwift_CanHavePlaceholderGenericTypeParameters.Type
    @_HashableExistential
    public var parameter: (any _StaticSwift_GenericTypeParameterNameProtocol)?
    
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

extension Never: _StaticSwift_GenericTypeParameterNameProtocol {
    
}
