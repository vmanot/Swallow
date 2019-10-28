//
// Copyright (c) Vatsal Manot
//

import Swift

extension Dictionary: KeyExposingMutableDictionaryProtocol {
    
}

extension Mirror: DictionaryProtocol {
    public subscript(key: String) -> Any? {
        return children
            .enumerated()
            .find({ key == $1.label ?? ".\(describe($0))" })?
            .1.value
    }
}
