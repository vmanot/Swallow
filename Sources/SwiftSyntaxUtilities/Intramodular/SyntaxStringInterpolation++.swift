//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension SyntaxStringInterpolation {
    // It would be nice for SwiftSyntaxBuilder to provide this out-of-the-box.
    @_disfavoredOverload
    public mutating func appendInterpolation<Node: SyntaxProtocol>(
        _ node: Node?
    ) {
        if let node {
            appendInterpolation(node)
        }
    }
}
