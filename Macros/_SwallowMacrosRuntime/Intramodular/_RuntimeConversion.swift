//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@objc open class _RuntimeConversion: NSObject {
    open class var type: Any.Type {
        assertionFailure()
        
        return Never.self
    }
}

public protocol _NonGenericRuntimeConversionProtocol: _RuntimeConversion {
    associatedtype Source
    associatedtype Destination
    
    static func __convert(_ source: Source) throws -> Destination
}

public protocol _GenericRuntimeConversionProtocol {
    static func __converts<T, U>(source: T.Type, to destination: U.Type) -> Bool
    static func __convert<T, U>(source: T, to destination: U.Type) throws -> U
}

public protocol _PerformOnceOnAppLaunch: Initiable {
    init()
    
    @discardableResult
    func perform() -> _SyncOrAsyncValue<Void>
}

public enum _GenericRuntimeConversions {
    
}

extension _GenericRuntimeConversions {
    public struct IdentifierIndexingArray_Array {
        public static func __converts<T, U>(
            source: T.Type,
            to destination: U.Type
        ) -> Bool {
            if source is any _IdentifierIndexingArrayOf_Protocol.Type && destination is any _ArrayProtocol.Type {
                return true
            }
            
            return false
        }
        
        public static func __convert<T, U>(source: T, to destination: U.Type) throws -> U {
            let source: any _IdentifierIndexingArrayOf_Protocol = try _forceCast(source)
            let destination: any _ArrayProtocol.Type = try _forceCast(destination)
            
            func _convert<X: _IdentifierIndexingArrayOf_Protocol>(_ x: X) throws -> U {
                func _convert<Y: _ArrayProtocol>(_ destinationType: Y.Type) throws -> U {
                    if X.Element.self == Y.Element.self {
                        return try x._ProtocolizableType_withInstance {
                            return try cast(Array($0), to: U.self)
                        }
                    } else {
                        fatalError(.unimplemented)
                    }
                }
                
                return try _openExistential(destination, do: _convert)
            }
            
            return try _openExistential(source, do: _convert)
        }
    }
}
