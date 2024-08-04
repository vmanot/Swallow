//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@objc(_Swallow_RuntimeFunctionDiscovery)
open class _RuntimeFunctionDiscovery: NSObject {
    public struct FunctionCaller: HashEquatable {
        public enum FunctionInvocationResult {
            case result(Result<Any, Error>)
            case promise(Task<Any, Error>)
        }
        
        public let id = UUID()
        
        public func hash(into hasher: inout Hasher) {
            id.hash(into: &hasher)
        }
        
        private let base: ([String: Any]) -> FunctionInvocationResult
        
        public init(_ function: @escaping ([String : Any]) throws -> Any) {
            self.base = { args in
                FunctionInvocationResult.result(Result(catching: { try function(args) }))
            }
        }
        
        public init(_ function: @escaping ([String : Any]) async throws -> Any) {
            self.base = { args in
                FunctionInvocationResult.promise(
                    Task {
                        try await function(args)
                    }
                )
            }
        }
        
        public func callAsFunction(
            _ args: [String: Any]
        ) throws -> FunctionInvocationResult {
            base(args)
        }
    }
    
    open class var attributes: Set<FunctionAttribute> {
        assertionFailure()
        
        return []
    }
    
    public static var caller: FunctionCaller {
        get throws {
            try Self.attributes.first(byUnwrapping: { (element) -> FunctionCaller? in
                guard case .caller(let f) = element else {
                    return nil
                }
                
                return f
            }).unwrap()
        }
    }
}

public struct _RuntimeDiscoveredFunction: Hashable, Identifiable {
    @_HashableExistential
    public var type: _RuntimeFunctionDiscovery.Type
    
    public init(_ type: _RuntimeFunctionDiscovery.Type) {
        self.type = type
    }
    
    public var id: AnyHashable {
        type.attributes
    }
}

extension _RuntimeFunctionDiscovery {
    public enum FunctionAttribute: Hashable {
        case name(String)
        case argument(name: String?, type: Metatype<Any.Type>)
        case returnType(Metatype<Any.Type>)
        case `throws`
        case `async`
        case sourceCodeLocation(SourceCodeLocation)
        case caller(FunctionCaller)
    }
}
