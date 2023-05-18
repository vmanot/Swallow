//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Tuple {
    associatedtype TupleElement
    associatedtype TupleElements
    
    var tupleElements: TupleElements { get }
    
    init(tupleElements: TupleElements)
    
    associatedtype TupleElementSequence: Sequence where TupleElementSequence.Element == TupleElement
    
    var tupleElementSequence: TupleElementSequence { get }
    
    init(tupleElementSequence: TupleElementSequence)
}

// MARK: - Derived Protocols -

public protocol ElementSingle: Tuple where TupleElements == TupleElement {
    associatedtype TupleElements = TupleElement
    associatedtype TupleElementSequence = CollectionOfOne<TupleElement>
}

public protocol TupleOf2: Tuple where TupleElements == (TupleElement, TupleElement) {
    associatedtype TupleElements = (TupleElement, TupleElement)
    associatedtype TupleElementSequence = CollectionOfTwo<TupleElement>
}

public protocol TupleOf3: Tuple where TupleElements == (TupleElement, TupleElement, TupleElement) {
    associatedtype TupleElements = (TupleElement, TupleElement, TupleElement)
    associatedtype TupleElementSequence = CollectionOfThree<TupleElement>
}

public protocol TupleOf4: Tuple where TupleElements == (TupleElement, TupleElement, TupleElement, TupleElement) {
    associatedtype TupleElements = (TupleElement, TupleElement, TupleElement, TupleElement)
    associatedtype TupleElementSequence = CollectionOfFour<TupleElement>
}

// MARK: - Implementation

extension ElementSingle where TupleElementSequence == CollectionOfOne<TupleElement> {
    public var tupleElementSequence: CollectionOfOne<TupleElement> {
        return CollectionOfOne(tupleElements)
    }
    
    public init(tupleElementSequence: TupleElementSequence) {
        self.init(tupleElements: tupleElementSequence[0])
    }
}

extension TupleOf2 where TupleElementSequence == CollectionOfTwo<TupleElement> {
    public var tupleElementSequence: CollectionOfTwo<TupleElement> {
        return CollectionOfOne(tupleElements.0)
            .join(CollectionOfOne(tupleElements.1))
    }
    
    public init(tupleElementSequence: TupleElementSequence) {
        self.init(tupleElements: (tupleElementSequence[0], tupleElementSequence[1]))
    }
}

extension TupleOf3 where TupleElementSequence == CollectionOfThree<TupleElement> {
    public var tupleElementSequence: CollectionOfThree<TupleElement> {
        return CollectionOfOne(tupleElements.0)
            .join(CollectionOfOne(tupleElements.1)
                    .join(CollectionOfOne(tupleElements.2)))
    }
    
    public init(tupleElementSequence: TupleElementSequence) {
        self.init(tupleElements: (tupleElementSequence[0], tupleElementSequence[1], tupleElementSequence[2]))
    }
}

extension TupleOf4 where TupleElementSequence == CollectionOfFour<TupleElement> {
    public var tupleElementSequence: CollectionOfFour<TupleElement> {
        return CollectionOfOne(tupleElements.0)
            .join(CollectionOfOne(tupleElements.1)
                    .join(CollectionOfOne(tupleElements.2)
                            .join(CollectionOfOne(tupleElements.3))))
    }
    
    public init(tupleElementSequence: TupleElementSequence) {
        self.init(tupleElements: (tupleElementSequence[0], tupleElementSequence[1], tupleElementSequence[2], tupleElementSequence[3]))
    }
}
