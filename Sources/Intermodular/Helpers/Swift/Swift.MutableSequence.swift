//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol MutableSequence: Sequence {
    mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows
    mutating func map<S: ExtensibleSequence & Initiable>(mutating iterator: ((inout Element) throws -> S.Element)) rethrows -> S
}

// MARK: - Implementation -

extension MutableSequence {
    public mutating func map<S: ExtensibleSequence & Initiable>(mutating iterator: ((inout Element) throws -> S.Element)) rethrows -> S {
        var result = S()
                
        try forEach(mutating: { (element: inout Element) in result += try iterator(&element) })
        
        return result
    }
}

extension MutableSequence where Self: MutableCollection {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        for index in indices {
            _ = try iterator(&self[index])
        }
    }
}

extension MutableSequence where Self: RangeReplaceableCollection {
    @inline(__always) public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        for (index, element) in enumerated() {
            var oldElementWasMutated = false
            
            var newElement = element {
                didSet {
                    oldElementWasMutated = true
                }
            }
            
            _ = try iterator(&newElement)
            
            if oldElementWasMutated {
                replaceSubrange(index..<self.index(index, offsetBy: 1), with: CollectionOfOne(newElement))
            }
        }
    }
}

extension MutableSequence where Self: MutableCollection & RangeReplaceableCollection {
    public mutating func forEach<T>(mutating iterator: ((inout Self.Element) throws -> T)) rethrows {
        for index in indices {
            _ = try iterator(&self[index])
        }
    }
}

// MARK: - Extensions -

extension MutableSequence where Element: Equatable {
    public mutating func replace(allOf some: Element, with other: Element) {
        forEach(mutating: { ($0 == some) &&-> ($0 = other) })
    }
}
