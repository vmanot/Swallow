//
// Copyright (c) Vatsal Manot
//

import Swift

extension DecodingError {
    public var context: DecodingError.Context? {
        switch self {
            case .typeMismatch(_, let context):
                return context
            case .valueNotFound(_, let context):
                return context
            case .keyNotFound(_, let context):
                return context
            case .dataCorrupted(let context):
                return context
            @unknown default:
                return nil
        }
    }
}

extension DecodingError.Context {
    public init(codingPath: [CodingKey]) {
        self.init(codingPath: codingPath, debugDescription: "Could not decode value")
    }
}
