//
// Copyright (c) Vatsal Manot
//

import Swift

extension CollectionOfOne.Iterator {
    public init(element: Element) {
        self = CollectionOfOne(element).makeIterator()
    }
}
