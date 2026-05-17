//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Structured representation of composed failures.
public indirect enum _ErrorFailureTree: Sendable {
    case error(AnyError)
    case relation(_ErrorFailureRelation)
}

/// Relationship between one or more composed failure nodes.
public struct _ErrorFailureRelation: Sendable {
    public var role: _ErrorFailureRelationRole
    public var children: [_ErrorFailureTree]
    public var context: [_ErrorContextBinding]

    public init(
        role: _ErrorFailureRelationRole,
        children: [_ErrorFailureTree],
        context: [_ErrorContextBinding] = []
    ) {
        self.role = role
        self.children = children
        self.context = context
    }
}

/// Meaning of a relationship between composed failure nodes.
public enum _ErrorFailureRelationRole: Hashable, Sendable, CustomStringConvertible {
    case primary
    case translatedFrom
    case contains
    case sequential
    case parallel
    case suppressed
    case cleanup
    case fallbackAttempt
    case cancellationConsequence

    public var description: String {
        switch self {
            case .primary:
                return "primary"
            case .translatedFrom:
                return "translated-from"
            case .contains:
                return "contains"
            case .sequential:
                return "sequential"
            case .parallel:
                return "parallel"
            case .suppressed:
                return "suppressed"
            case .cleanup:
                return "cleanup"
            case .fallbackAttempt:
                return "fallback-attempt"
            case .cancellationConsequence:
                return "cancellation-consequence"
        }
    }
}

/// Error that provides its full composed failure tree.
public protocol _ErrorFailureTreeRepresentable {
    var errorFailureTree: _ErrorFailureTree { get }
}

/// Error that provides related failures in addition to itself.
public protocol _ErrorRelatedFailuresRepresentable {
    var relatedErrorFailures: [_ErrorFailureRelation] { get }
}

extension _ErrorFailureTree {
    public static func failure(
        _ error: some Error
    ) -> Self {
        .error(AnyError(erasing: error._errorXBase))
    }

    public static func primary(
        _ children: [Self],
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .primary, children: children, context: context))
    }

    public static func contains(
        _ children: [Self],
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .contains, children: children, context: context))
    }

    public static func contains(
        _ error: some Error,
        related children: [Self],
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .contains([.failure(error)] + children, context: context)
    }

    public static func translatedFrom(
        _ child: Self,
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .translatedFrom, children: [child], context: context))
    }

    public static func parallel(
        _ children: [Self],
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .parallel, children: children, context: context))
    }

    public static func sequential(
        _ children: [Self],
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .sequential, children: children, context: context))
    }

    public static func suppressed(
        _ child: Self,
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .suppressed, children: [child], context: context))
    }

    public static func cleanup(
        _ child: Self,
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .cleanup, children: [child], context: context))
    }

    public static func fallbackAttempt(
        _ child: Self,
        context: [_ErrorContextBinding] = []
    ) -> Self {
        .relation(.init(role: .fallbackAttempt, children: [child], context: context))
    }

    public init(
        chain: _ErrorChain
    ) {
        if chain.elements.count == 1, let element = chain.elements.first {
            self = .error(element)
        } else {
            self = .relation(
                .init(
                    role: .primary,
                    children: chain.elements.map {
                        .error($0)
                    }
                )
            )
        }
    }
}
