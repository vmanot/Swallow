//
// Copyright (c) Vatsal Manot
//

import Swift

extension LazyMapCollection {
    public var base: Base {
        undocumented {
            unsafeBitCast(self, to: ((Base), ((Base.Element) -> Element)).self).0
        }
    }
}
