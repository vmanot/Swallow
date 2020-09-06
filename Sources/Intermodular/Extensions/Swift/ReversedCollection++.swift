//
// Copyright (c) Vatsal Manot
//

import Swift

extension ReversedCollection {
    public var base: Base {
        return undocumented {
            unsafeBitCast(self)
        }
    }
}
