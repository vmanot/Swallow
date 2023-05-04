//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol JoinableSequence: Sequence {
    associatedtype JointSequenceType: Sequence = Join2Sequence<Self, Self> where JointSequenceType.Element == Element 
    
    func join(_: Self) -> JointSequenceType
}

public protocol JoinableCollection: Collection, JoinableSequence where Index: Strideable, JointSequenceType: Collection, JointSequenceType.Index == Index {
    associatedtype JointSequenceType = Join2Collection<Self, Self>
}

// MARK: - Implementation

extension JoinableSequence where JointSequenceType == Join2Sequence<Self, Self> {
    public func join(_ other: Self) -> JointSequenceType {
        return .init((self, other))
    }
}

extension JoinableCollection where JointSequenceType == Join2Collection<Self, Self> {
    public func join(_ other: Self) -> JointSequenceType {
        return .init((self, other))
    }
}
