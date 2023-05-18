//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A recursively traversable sequence.
public protocol RecursiveSequence: Sequence where Element: EitherRepresentable, Element.LeftValue == Unit, Element.RightValue == Self {
    associatedtype Unit
    
    var isUnit: Bool { get }
    
    func recursiveForEach<T>(_: ((Unit) throws -> T)) rethrows
    func recursiveMap<RDS: SequenceInitiableRecursiveSequence>(_: ((Unit) throws -> RDS.Unit)) rethrows -> RDS
    func recursiveFilter<RDS: SequenceInitiableRecursiveSequence>(_: ((Unit) throws -> Bool)) rethrows -> RDS where RDS.Unit == Unit
    func recursiveReduce<T>(_: T, _: ((T, Unit) throws -> T)) rethrows -> T
    func recursiveReduce<T>(_: ((T?, Unit?) throws -> T?)) rethrows -> T?
    func recursiveCompactReduce(_: ((Unit, Unit) throws -> Unit)) rethrows -> Unit?
    func recursiveCompactConcatenate<S: SequenceInitiableSequence>(_: ((S) throws -> Unit)) rethrows -> Unit? where S.Element == Unit
}

public protocol SequenceInitiableRecursiveSequence: RecursiveSequence, SequenceInitiableSequence {
    init(unit: Unit)
    
    init<S: Sequence>(_: S) where S.Element == Unit
    init<C: Collection>(_: C) where C.Element == Unit
    init<BC: BidirectionalCollection>(_: BC) where BC.Element == Unit
    init<RAC: RandomAccessCollection>(_: RAC) where RAC.Element == Unit
    
    init<S: Sequence>(_: S) where S.Element == Self
    init<C: Collection>(_: C) where C.Element == Self
    init<BC: BidirectionalCollection>(_: BC) where BC.Element == Self
    init<RAC: RandomAccessCollection>(_: RAC) where RAC.Element == Self
    
    init<S: Sequence>(_: S) where S.Element: EitherRepresentable, S.Element.LeftValue == Unit, S.Element.RightValue == Self
    init<C: Collection>(_: C) where C.Element: EitherRepresentable, C.Element.LeftValue == Unit, C.Element.RightValue == Self
    init<BC: BidirectionalCollection>(_: BC) where BC.Element: EitherRepresentable, BC.Element.LeftValue == Unit, BC.Element.RightValue == Self
    init<RAC: RandomAccessCollection>(_: RAC) where RAC.Element: EitherRepresentable, RAC.Element.LeftValue == Unit, RAC.Element.RightValue == Self
}

// MARK: - Implementation

extension SequenceInitiableRecursiveSequence  {
    public init<S: Sequence>(_ sequence: S) where S.Element == Unit {
        self.init(sequence.lazy.map({ .init(leftValue: $0) }))
    }
    
    public init<C: Collection>(_ collection: C) where C.Element == Unit {
        self.init(collection.lazy.map({ .init(leftValue: $0) }))
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Element == Self {
        self.init(sequence.lazy.map({ .init(rightValue: $0) }))
    }
    
    public init<C: Collection>(_ collection: C) where C.Element == Self {
        self.init(collection.lazy.map({ .init(rightValue: $0) }))
    }
}
