//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OrderedCollection: Collection {
	func prefix(upTo upperBound: Element) -> SubSequence
	func suffix(from lowerBound: Element) -> SubSequence
}

// MARK: - Concrete Implementations -

extension DefaultIndices: OrderedCollection {
    
}
