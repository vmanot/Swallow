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

/*extension TypeMetadata {
    public func conforms(to type: Any.Type) -> Bool {
        guard let protocolType = TypeMetadata.Existential(type) else {
            return false
        }
        
        return _conformsToProtocol(base, protocolType.metadata.metadata.pointee.protocolDescriptorVector) != nil
    }
}

@_silgen_name("swift_conformsToProtocol")
private func _conformsToProtocol(
    _ type: Any.Type,
    _ protocolDescriptor: UnsafeMutablePointer<SwiftRuntimeProtocolContextDescriptor>
) -> UnsafeRawPointer?
*/
