//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    @frozen
    public struct Existential: SwiftRuntimeTypeMetadataWrapper {
        typealias SwiftRuntimeTypeMetadata = SwiftRuntimeProtocolMetadata
        
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .existential else {
                return nil
            }
            
            self.base = base
        }
        
        public var mangledName: String {
            return metadata.mangledName()
        }
    }
}

extension TypeMetadata {
    @_optimize(speed)
    @_transparent
    public func conforms(
        to testType: Any.Type
    ) -> Bool {
        func _conformsToType<A>(
            _ type: A.Type
        ) -> Bool {
            self.base is A.Type
        }
        
        func _conformsToMetatype<A>(
            _ type: A.Type
        ) -> Bool {
            self.base is A
        }
        
        if _openExistential(testType, do: _conformsToType) {
            return true
        }
        
        if let existentialMetatype = _swift_getExistentialMetatypeMetadata(testType) {
            if _openExistential(existentialMetatype, do: _conformsToMetatype) {
                return true
            }
        }

        /*guard let protocolType = TypeMetadata.Existential(testType) else {
            return false
        }*/

        return false
        
        /*
        let protocolDescriptor = protocolType.metadata.metadata.pointee.protocolDescriptorVector
        
        return _conformsToProtocol(base, protocolDescriptor) != nil*/
    }
    
    @_optimize(speed)
    @_transparent
    public func _conforms(
        toExistentialMetatype testType: Any.Type
    ) -> Bool {
        @_optimize(speed)
        @_transparent
        func _conformsToMetatype<A>(
            _ type: A.Type
        ) -> Bool {
            self.base is A
        }
        
        return _openExistential(testType, do: _conformsToMetatype)
    }
    
    @_optimize(speed)
    @_transparent
    public func conforms(
        to testType: TypeMetadata
    ) -> Bool {
        conforms(to: testType.base)
    }
}

extension Metatype {
    public func conforms<U>(
        to other: Metatype<U>
    ) -> Bool {
        TypeMetadata(_unwrapBase()).conforms(to: other._unwrapBase())
    }
}

@_silgen_name("swift_conformsToProtocol")
@usableFromInline
func _conformsToProtocol(
    _ type: Any.Type,
    _ protocolDescriptor: UnsafeMutablePointer<SwiftRuntimeProtocolContextDescriptor>
) -> UnsafeRawPointer?

@_silgen_name("swift_getExistentialMetatypeMetadata")
@usableFromInline
func _swift_getExistentialMetatypeMetadata(
    _ instanceType: Any.Type
) -> Any.Type?
