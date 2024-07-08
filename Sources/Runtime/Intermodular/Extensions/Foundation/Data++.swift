//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Data {
    public init(from value: NSValue) throws {
        self = .allocate(
            byteCount: try value.objCTypeEncoding.sizeInBytes,
            alignment: value.objCTypeEncoding.alignmentInBytes
        )

        withUnsafeMutableBytes({ value.getValue($0.baseAddress!) })
    }
}
