//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol _ErrorTraitsBuilding {
    
}

extension _ErrorTraitsBuilding {
    public typealias Domain = _SubsystemDomainErrorTrait
}

@frozen
public struct ErrorTraits: Hashable, @unchecked Sendable {
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
                    $0 as? _SubsystemDomainErrorTrait
                }
                .map {
                    $0.domain
                }
        )
    }
}

extension ErrorTraits {
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(storage: lhs.storage.union(rhs.storage))
    }
    
    public static func += (lhs: inout Self, rhs: Self)  {
        lhs = lhs + rhs
    }
}

extension ErrorTraits: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(storage: .init(elements))
    }
}

@resultBuilder
public struct ErrorTraitsBuilder {
    public static func buildBlock(_ element: ErrorTraits) -> ErrorTraits {
        element
    }
        
    public static func buildIf(_ content: ErrorTraits?) -> ErrorTraits {
        if let content = content {
            return buildBlock(content)
        } else {
            return []
        }
    }
    
    public static func buildEither(first: ErrorTraits) -> ErrorTraits {
        buildBlock(first)
    }
    
    public static func buildEither(second: ErrorTraits) -> ErrorTraits {
        buildBlock(second)
    }
    
    public static func buildPartialBlock(
        first: ErrorTraits
    ) -> ErrorTraits {
        first
    }
    
    public static func buildPartialBlock(
        accumulated: ErrorTraits,
        next: ErrorTraits
    ) -> ErrorTraits {
        ErrorTraits(storage: accumulated.storage.union(next.storage))
    }
}
