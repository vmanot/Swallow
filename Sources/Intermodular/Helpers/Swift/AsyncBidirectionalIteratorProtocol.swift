//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that asynchronously supplies the values of a sequence one at a time.
public protocol AsyncBidirectionalIteratorProtocol: AsyncIteratorProtocol {
    mutating func previous() async throws -> Element?
}
