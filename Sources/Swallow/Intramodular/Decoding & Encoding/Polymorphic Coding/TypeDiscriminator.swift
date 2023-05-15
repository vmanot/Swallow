//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol TypeDiscriminator: Hashable {
    associatedtype _DiscriminatedSwiftType: _StaticSwiftType = _OpaqueExistentialSwiftType
    
    func resolveType() throws -> _DiscriminatedSwiftType._Metatype
}

public protocol TypeDiscriminatorDecoding {
    associatedtype TypeDiscriminator
    
    func decodeTypeDiscriminator(from decoder: Decoder) throws -> TypeDiscriminator
}
