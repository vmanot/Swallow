//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ForwardIndex: _opaque_ForwardIndex, Comparable {
    associatedtype Distance: SignedInteger = Int

    /// The logical successor to `self`.
    func successor() -> Self
}

public protocol BidirectionalIndex: _opaque_BidirectionalIndex, ForwardIndex {
    /// The logical predecessor to `self`.
    func predecessor() -> Self
}

public protocol RandomAccessIndex: _opaque_RandomAccessIndex, BidirectionalIndex, Strideable2 {

}

// MARK: - Extensions -

extension RandomAccessIndex {
    public static func - (lhs: Self, rhs: Stride) -> Self {
        return lhs.advanced(by: -rhs)
    }

    public static func -= (lhs: inout Self, rhs: Stride) {
        lhs.advance(by: -rhs)
    }
}
