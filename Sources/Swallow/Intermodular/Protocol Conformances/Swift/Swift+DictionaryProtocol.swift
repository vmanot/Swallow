//
// Copyright (c) Vatsal Manot
//

import Swift

extension Dictionary: KeyExposingMutableDictionaryProtocol {
    
}

extension Mirror: DictionaryProtocol {
    public typealias DictionaryKey = String
    
    public subscript(key: String) -> Any? {
        return children
            .enumerated()
            .find({ key == $1.label ?? ".\(String(describing: $0))" })?
            .1.value
    }
    
    @dynamicMemberLookup
    public struct DynamicMemberLookup {
        public struct Key {
            fileprivate let value: String
        }
        
        public subscript(dynamicMember key: String) -> Key {
            Key(value: key)
        }
    }
    
    public subscript(keyPath path: KeyPath<Mirror.DynamicMemberLookup, Mirror.DynamicMemberLookup.Key>) -> Any? {
        self[DynamicMemberLookup()[keyPath: path].value]
    }
}
