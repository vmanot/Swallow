//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ForwardIndexProtocol: Comparable {
    associatedtype Distance: SignedInteger = Int

    /// The logical successor to `self`.
    func successor() -> Self
}

public protocol BidirectionalIndexProtocol: ForwardIndexProtocol {
    /// The logical predecessor to `self`.
    func predecessor() -> Self
}

public protocol RandomAccessIndexProtocol: BidirectionalIndexProtocol, Strideable {

}

// MARK: - Extensions

extension RandomAccessIndexProtocol {
    public static func - (lhs: Self, rhs: Stride) -> Self {
        return lhs.advanced(by: -rhs)
    }

    public static func -= (lhs: inout Self, rhs: Stride) {
        lhs.advance(by: -rhs)
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "ForwardIndexProtocol")
public typealias ForwardIndex = ForwardIndexProtocol
@available(*, deprecated, renamed: "BidirectionalIndexProtocol")
public typealias BidirectionalIndex = BidirectionalIndexProtocol
@available(*, deprecated, renamed: "BidirectionalIndexProtocol")
public typealias RandomAccessIndex = RandomAccessIndexProtocol
