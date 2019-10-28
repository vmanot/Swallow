//
// Copyright (c) Vatsal Manot
//

import Swift

extension Array: ExtensibleSequence {
    public mutating func insert(_ newElement: Element) {
        insert(newElement, at: 0)
    }
}

extension Dictionary: ExtensibleSequence {
    public mutating func insert(_ newElement: Element) {
       append(newElement)
    }

    public mutating func append(_ newElement: Element) {
        self[newElement.0] = newElement.1
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        newElements.forEach({ self.append($0) })
    }
}

extension String: ExtensibleSequence {
    public mutating func insert(_ newElement: Element) {
        insert(newElement, at: startIndex)
    }
}

extension Set: ExtensibleSequence {    
    public mutating func append(_ newElement: Element) {
        insert(newElement)
    }
}

extension String.UnicodeScalarView: ExtensibleRangeReplaceableCollection {

}
