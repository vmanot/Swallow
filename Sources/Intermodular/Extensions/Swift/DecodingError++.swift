//
// Copyright (c) Vatsal Manot
//

import Swift

extension DecodingError.Context {
    public init(codingPath: [CodingKey]) {
        self.init(codingPath: codingPath, debugDescription: "Could not decode value")
    }
}
