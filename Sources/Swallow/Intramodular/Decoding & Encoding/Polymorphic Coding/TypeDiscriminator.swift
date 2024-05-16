//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol TypeDiscriminator: Hashable {
    associatedtype _DiscriminatedSwiftType: _StaticSwiftType = _OpaqueExistentialSwiftType
    
    static var _undiscriminatedType: Any.Type? { get }
    
    func resolveType() throws -> _DiscriminatedSwiftType._Metatype
}

extension TypeDiscriminator {
    public static var _undiscriminatedType: Any.Type? {
        nil
    }
}

public protocol TypeDiscriminatorDecoding {
    associatedtype TypeDiscriminator
    
    func decodeTypeDiscriminator(from decoder: Decoder) throws -> TypeDiscriminator
}
