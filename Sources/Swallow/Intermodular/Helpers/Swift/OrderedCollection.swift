//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OrderedCollection: Collection {
	func prefix(upTo upperBound: Element) -> SubSequence
	func suffix(from lowerBound: Element) -> SubSequence
}

// MARK: - Conformances

extension DefaultIndices: OrderedCollection {
    
}
