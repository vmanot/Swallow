//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Type that can provide `_ErrorTrait` values.
public protocol _ErrorTraitsBuilding {

}

extension _ErrorTraitsBuilding {
    public typealias Domain = _ErrorDomainTrait
}

/// Ordered set-like collection of typed error traits.
@frozen
public struct _ErrorTraits: Hashable, Countable, @unchecked Sendable {
    public typealias Element = any _ErrorTrait

    let storage: _ExistentialSet<any _ErrorTrait>

    init(storage: _ExistentialSet<any _ErrorTrait>) {
        self.storage = storage
    }

    public var domains: _ExistentialSet<any _SubsystemDomain> {
        _ExistentialSet(
            storage
                .lazy
                .compactMap {
                    $0 as? _ErrorDomainTrait
                }
                .map {
                    $0.domain
                }
        )
    }

    public var elements: [Element] {
        Array(storage)
    }

    public var count: Int {
        storage.count
    }

    public func first<T: _ErrorTrait>(
        of type: T.Type
    ) -> T? {
        elements.first(where: { $0 is T }) as? T
    }

    public func all<T: _ErrorTrait>(
        of type: T.Type
    ) -> [T] {
        elements.compactMap({ $0 as? T })
    }
}

extension _ErrorTraits {
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(storage: lhs.storage.union(rhs.storage))
    }

    public static func += (lhs: inout Self, rhs: Self)  {
        lhs = lhs + rhs
    }
}

extension _ErrorTraits: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(storage: .init(elements))
    }
}

@resultBuilder
/// Result builder for composing `_ErrorTraits`.
public struct _ErrorTraitsBuilder {
    public static func buildBlock(_ element: _ErrorTraits) -> _ErrorTraits {
        element
    }

    public static func buildIf(_ content: _ErrorTraits?) -> _ErrorTraits {
        if let content = content {
            return buildBlock(content)
        } else {
            return []
        }
    }

    public static func buildEither(first: _ErrorTraits) -> _ErrorTraits {
        buildBlock(first)
    }

    public static func buildEither(second: _ErrorTraits) -> _ErrorTraits {
        buildBlock(second)
    }

    public static func buildPartialBlock(
        first: _ErrorTraits
    ) -> _ErrorTraits {
        first
    }

    public static func buildPartialBlock(
        accumulated: _ErrorTraits,
        next: _ErrorTraits
    ) -> _ErrorTraits {
        _ErrorTraits(storage: accumulated.storage.union(next.storage))
    }
}
