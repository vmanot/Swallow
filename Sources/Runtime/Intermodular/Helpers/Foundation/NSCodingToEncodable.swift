//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct NSCodingToEncodable: Encodable {
    public let base: NSCoding

    public init(base: NSCoding) {
        self.base = base
    }

    public func encode(to encoder: Encoder) throws {
        base.encode(with: EncoderNSCodingAdaptor(base: encoder))
    }
}
