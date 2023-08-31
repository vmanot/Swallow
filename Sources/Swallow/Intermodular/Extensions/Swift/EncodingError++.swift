//
// Copyright (c) Vatsal Manot
//

import Swift

extension EncodingError {
    public var context: EncodingError.Context? {
        switch self {
            case .invalidValue(_, let context):
                return context
            @unknown default:
                return nil
        }
    }
}

extension EncodingError.Context {
    public init(codingPath: [CodingKey]) {
        self.init(codingPath: codingPath, debugDescription: String())
    }
}
