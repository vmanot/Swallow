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
