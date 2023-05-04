//
// Copyright (c) Vatsal Manot
//

import Swift

extension EncodingError.Context {
    public init(codingPath: [CodingKey]) {
        self.init(codingPath: codingPath, debugDescription: String())
    }
}
