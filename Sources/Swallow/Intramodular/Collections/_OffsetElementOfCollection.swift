//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct _OffsetElementOfCollection<Element>: Identifiable {
    public let offset: Int
    public let element: Element
    
    public var id: Int {
        offset
    }
    
    public init(offset: Int, element: Element) {
        self.offset = offset
        self.element = element
    }
}

public struct _ElementOffsetInParentCollection: Hashable {
    /// The offset of the element.
    public let offset: Int
    /// The bounds of the parent collection of the element.
    public let bounds: Range<Int>
    
    public var isLastElement: Bool {
        let lastOffset = bounds.upperBound - 1
        
        guard lastOffset >= 0 else {
            return false
        }
        
        return offset == lastOffset
    }

    public init(offset: Int, in bounds: Range<Int>) {
        self.offset = offset
        self.bounds = bounds
    }
}
