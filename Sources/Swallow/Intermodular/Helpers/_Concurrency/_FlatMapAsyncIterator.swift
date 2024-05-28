//
// Copyright (c) Vatsal Manot
//

import Swift

/// An asynchronous iterator that applies a transformation to elements of another iterator where the transformation itself produces an async sequence.
public struct _FlatMapAsyncIterator<Base: AsyncIteratorProtocol, SegmentOfResult: AsyncSequence>: AsyncIteratorProtocol {
    public typealias Element = SegmentOfResult.Element
    
    private var baseIterator: Base
    private let transform: (Base.Element) async throws -> SegmentOfResult
    private var currentIterator: SegmentOfResult.AsyncIterator?
    
    public init(
        base: Base,
        transform: @escaping (Base.Element) async throws -> SegmentOfResult
    ) {
        self.baseIterator = base
        self.transform = transform
    }
    
    public  mutating func next() async throws -> SegmentOfResult.Element? {
        while true {
            if let current = try await currentIterator?.next() {
                return current
            }
            let nextBaseElement = try await baseIterator.next()
            if let element = nextBaseElement {
                let newSequence = try await transform(element)
                currentIterator = newSequence.makeAsyncIterator()
            } else {
                return nil
            }
        }
    }
}

/// Example usage
struct MyAsyncSequence: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Int
    private var current = 0
    
    func makeAsyncIterator() -> MyAsyncSequence {
        return self
    }
    
    mutating func next() async throws -> Int? {
        defer { current += 1 }
        return current < 10 ? current : nil
    }
}

extension AsyncIteratorProtocol {
    /// Returns an AsyncIteratorProtocol that flat-maps the elements of this sequence using the provided asynchronous transform function.
    public func _flatMap<SegmentOfResult: AsyncSequence>(
        _ transform: @escaping (Element) async throws -> SegmentOfResult
    ) -> _FlatMapAsyncIterator<Self, SegmentOfResult> {
        _FlatMapAsyncIterator(base: self, transform: transform)
    }
    
    /// Returns an AsyncIteratorProtocol that flat-maps the elements of this sequence using the provided asynchronous transform function.
    public func _flatMap<SegmentOfResult: Sequence>(
        _ transform: @escaping (Element) async throws -> SegmentOfResult
    ) -> _FlatMapAsyncIterator<Self, AnyAsyncSequence<SegmentOfResult.Element>> {
        _FlatMapAsyncIterator(base: self, transform: { try await AnyAsyncSequence<SegmentOfResult.Element>(transform($0)) })
    }
}
