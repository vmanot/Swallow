//
// Copyright (c) Vatsal Manot
//

import Swift

/// A path that supports embedding a value in a root and attempting to extract a root's embedded
/// value.
///
/// This type defines key path-like semantics for enum cases.
public struct CasePath<_Root, _Value> {
    public typealias Root = _Root
    public typealias Value = _Value
    
    private let _embed: (Value) -> Root
    private let _extract: (Root) -> Value?
    
    /// Creates a case path with a pair of functions.
    ///
    /// - Parameters:
    ///   - embed: A function that always succeeds in embedding a value in a root.
    ///   - extract: A function that can optionally fail in extracting a value from a root.
    public init(
        embed: @escaping (Value) -> Root,
        extract: @escaping (Root) -> Value?
    ) {
        self._embed = { value in
            lock.withCriticalScope {
                embed(value)
            }
        }
        self._extract = { root in
            lock.withCriticalScope {
                extract(root)
            }
        }
    }
    
    /// Returns a root by embedding a value.
    ///
    /// - Parameter value: A value to embed.
    /// - Returns: A root that embeds `value`.
    public func embed(_ value: Value) -> Root {
        self._embed(value)
    }
    
    /// Attempts to extract a value from a root.
    ///
    /// - Parameter root: A root to extract from.
    /// - Returns: A value if it can be extracted from the given root, otherwise `nil`.
    public func extract(from root: Root) -> Value? {
        self._extract(root)
    }
    
    /// Attempts to modify a value in a root.
    ///
    /// - Parameters:
    ///   - root: A root to modify if the case path matches.
    ///   - body: A closure that can mutate the case's associated value. If the closure throws, the root
    ///     will be left unmodified.
    /// - Returns: The return value, if any, of the body closure.
    public func modify<Result>(
        _ root: inout Root,
        _ body: (inout Value) throws -> Result
    ) throws -> Result {
        guard var value = self.extract(from: root) else { throw ExtractionFailed() }
        let result = try body(&value)
        root = self.embed(value)
        return result
    }
    
    /// Returns a new case path created by appending the given case path to this one.
    ///
    /// Use this method to extend this case path to the value type of another case path.
    ///
    /// - Parameter path: The case path to append.
    /// - Returns: A case path from the root of this case path to the value type of `path`.
    public func appending<AppendedValue>(path: CasePath<Value, AppendedValue>) -> CasePath<
        Root, AppendedValue
    > {
        CasePath<Root, AppendedValue>(
            embed: { self.embed(path.embed($0)) },
            extract: { self.extract(from: $0).flatMap(path.extract) }
        )
    }
}

// MARK: - Conformances

extension CasePath: @unchecked Sendable {
    
}

extension CasePath: CustomStringConvertible {
    public var description: String {
        "CasePath<\(Metatype(Root.self)), \(Metatype(Value.self))>"
    }
}

struct ExtractionFailed: Error {
    
}

private let lock = OSUnfairLock()

public protocol _CasePathExtracting {
    
}

extension _CasePathExtracting {
    /// Returns the value extracted using the given `CasePath`, or `nil` if the extraction fails.
    ///
    /// - Parameter casePath: The `CasePath` to use for extraction.
    /// - Returns: The value extracted using the given `CasePath`, or `nil` if the extraction fails.
    public subscript<Value>(casePath path: CasePath<Self, Value>) -> Value? {
        path.extract(from: self)
    }
}

extension Sequence where Element: _CasePathExtracting {
    public func first<Value>(
        _ casePath: CasePath<Element, Value>
    ) -> Value? {
        first(byUnwrapping: { $0[casePath: casePath] })
    }

    public func first<T0, T1>(
        _ first: CasePath<Element, T0>,
        _ second: CasePath<T0, T1>
    ) -> T1? {
        self.first(byUnwrapping: {
            first.extract(from: $0).flatMap({ second.extract(from: $0) })
        })
    }
}
