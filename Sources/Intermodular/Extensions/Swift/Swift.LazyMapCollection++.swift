//
// Copyright (c) Vatsal Manot
//

import Swift

extension LazyMapCollection {
    public var base: Base {
        return undocumented {
            let _self = -*>self as ((Base), ((Base.Element) -> Element))

            return _self.0
        }
    }
}
