//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
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
    public func conforms(to testType: Any.Type) -> Bool {
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

        guard let protocolType = TypeMetadata.Existential(testType) else {
            return false
        }

        return _conformsToProtocol(base, protocolType.metadata.metadata.pointee.protocolDescriptorVector) != nil
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
func _conformsToProtocol(
    _ type: Any.Type,
    _ protocolDescriptor: UnsafeMutablePointer<SwiftRuntimeProtocolContextDescriptor>
) -> UnsafeRawPointer?

@_silgen_name("swift_getExistentialMetatypeMetadata")
func _swift_getExistentialMetatypeMetadata(
    _ instanceType: Any.Type
) -> Any.Type?
