//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Observation-time read model for an error.
public struct _ErrorReport: Sendable {
    /// Stable identity found at a position in the primary cause chain.
    public struct IdentityOccurrence: Sendable {
        public var chainIndex: Int
        public var error: AnyError
        public var identity: _ErrorIdentity

        public init(
            chainIndex: Int,
            error: AnyError,
            identity: _ErrorIdentity
        ) {
            self.chainIndex = chainIndex
            self.error = error
            self.identity = identity
        }
    }

    /// Stable identity found at a position in the composed failure tree.
    public struct FailureIdentityOccurrence: Sendable {
        public var path: [Int]
        public var relationRoles: [_ErrorFailureRelationRole]
        public var error: AnyError
        public var identity: _ErrorIdentity

        public init(
            path: [Int],
            relationRoles: [_ErrorFailureRelationRole],
            error: AnyError,
            identity: _ErrorIdentity
        ) {
            self.path = path
            self.relationRoles = relationRoles
            self.error = error
            self.identity = identity
        }
    }

    /// Context found at a position in the composed failure tree.
    public struct FailureContextOccurrence: Hashable, Sendable {
        public var path: [Int]
        public var relationRoles: [_ErrorFailureRelationRole]
        public var context: _ErrorContextBinding

        public init(
            path: [Int],
            relationRoles: [_ErrorFailureRelationRole],
            context: _ErrorContextBinding
        ) {
            self.path = path
            self.relationRoles = relationRoles
            self.context = context
        }
    }

    public var root: AnyError
    public var chain: _ErrorChain
    public var failureTree: _ErrorFailureTree
    public var scenario: _AnyErrorReportScenario?
    public var identity: _ErrorIdentity?
    public var identityOccurrences: [IdentityOccurrence]
    public var failureIdentityOccurrences: [FailureIdentityOccurrence]
    public var failureContextOccurrences: [FailureContextOccurrence]
    public var traits: _ErrorTraits
    public var presentation: _ErrorPresentation?
    public var recoverySuggestions: [_ErrorRecoverySuggestion]
    public var context: [_ErrorContextBinding]
    public var observation: _ErrorObservationContext

    public init(
        root: AnyError,
        chain: _ErrorChain,
        identity: _ErrorIdentity?,
        identityOccurrences: [IdentityOccurrence] = [],
        failureIdentityOccurrences: [FailureIdentityOccurrence] = [],
        failureContextOccurrences: [FailureContextOccurrence] = [],
        traits: _ErrorTraits,
        presentation: _ErrorPresentation?,
        recoverySuggestions: [_ErrorRecoverySuggestion],
        context: [_ErrorContextBinding],
        observation: _ErrorObservationContext,
        failureTree: _ErrorFailureTree? = nil,
        scenario: _AnyErrorReportScenario? = nil
    ) {
        let resolvedFailureTree = failureTree ?? _ErrorFailureTree(chain: chain)
        let topology = _ErrorFailureTopology(resolvedFailureTree)

        self.root = root
        self.chain = chain
        self.failureTree = resolvedFailureTree
        self.scenario = scenario ?? observation.scenario
        self.identity = identity
        self.identityOccurrences = identityOccurrences
        self.failureIdentityOccurrences = failureIdentityOccurrences.isEmpty
            ? topology.identityOccurrences().map(FailureIdentityOccurrence.init)
            : failureIdentityOccurrences
        self.failureContextOccurrences = failureContextOccurrences.isEmpty
            ? topology.contextOccurrences().map(FailureContextOccurrence.init)
            : failureContextOccurrences
        self.traits = traits
        self.presentation = presentation
        self.recoverySuggestions = recoverySuggestions
        self.context = context
        self.observation = observation
    }
}

/// Boundary namespace for observing errors as diagnostic reports.
public enum _ErrorReporting {
    public static func report(
        _ error: any Swift.Error,
        scenario: some _ErrorReportScenario,
        context: [_ErrorContextBinding] = []
    ) -> _ErrorReport {
        report(
            error,
            observation: .init(
                scenario: .init(scenario),
                contextBindings: context
            )
        )
    }

    public static func report(
        _ error: any Swift.Error,
        observation: _ErrorObservationContext = .init()
    ) -> _ErrorReport {
        let chain = error._errorChain
        let failureTree = _ErrorReport._failureTree(for: error, chain: chain)
        let topology = _ErrorFailureTopology(failureTree)
        let failureIdentityOccurrences = _ErrorReport._failureIdentityOccurrences(in: topology)
        let traits = chain.elements.reduce(_ErrorTraits()) { partialResult, element in
            partialResult + ((element.base._errorXBase as? any _ErrorX)?.traits ?? [])
        }

        return _ErrorReport(
            root: AnyError(erasing: error._errorXBase),
            chain: chain,
            identity: _ErrorReport._headlineIdentity(
                root: error._errorXBase,
                failureIdentityOccurrences: failureIdentityOccurrences
            ),
            identityOccurrences: _ErrorReport._identityOccurrences(in: chain),
            failureIdentityOccurrences: failureIdentityOccurrences,
            traits: traits,
            presentation: _ErrorReport._presentation(in: chain, traits: traits),
            recoverySuggestions: _ErrorReport._recoverySuggestions(in: chain, traits: traits),
            context: _ErrorReport._context(
                in: topology,
                traits: traits,
                observation: observation
            ),
            observation: observation,
            failureTree: failureTree
        )
    }

    public static func report<Failure: _ErrorX>(
        _ error: Failure,
        observation: _ErrorObservationContext = .init()
    ) -> _ErrorReport {
        report(error as any Swift.Error, observation: observation)
    }

}

extension Error {
    public func _errorReport(
        scenario: some _ErrorReportScenario,
        context: [_ErrorContextBinding] = []
    ) -> _ErrorReport {
        _ErrorReporting.report(self as any Swift.Error, scenario: scenario, context: context)
    }

    public func _errorReport(
        observation: _ErrorObservationContext = .init()
    ) -> _ErrorReport {
        _ErrorReporting.report(self as any Swift.Error, observation: observation)
    }
}

extension _ErrorReport {
    public var headlineIdentity: _ErrorIdentity? {
        identity
    }

    public var domain: _SubsystemDomainIdentifier? {
        identity?.domain
    }

    public var code: String? {
        identity?.code
    }

    public var summary: String? {
        presentation?.summary
    }

    public var reason: String? {
        presentation?.reason
    }

    public var identities: [_ErrorIdentity] {
        identityOccurrences.map(\.identity)
    }

    public var allIdentities: [_ErrorIdentity] {
        failureIdentityOccurrences.map(\.identity)
    }

    public func contains(
        identity: _ErrorIdentity
    ) -> Bool {
        allIdentities.contains(identity)
    }

    public func identities(
        in role: _ErrorFailureRelationRole
    ) -> [_ErrorIdentity] {
        failureIdentityOccurrences.compactMap { occurrence in
            occurrence.relationRoles.contains(role) ? occurrence.identity : nil
        }
    }

    public func failureContextOccurrences(
        in role: _ErrorFailureRelationRole
    ) -> [FailureContextOccurrence] {
        failureContextOccurrences.filter { occurrence in
            occurrence.relationRoles.contains(role)
        }
    }

    public func failures<Failure: Error>(
        of type: Failure.Type
    ) -> [Failure] {
        var result: [Failure] = []

        failureTree._errorXForEachError { error in
            if let match = error.base._errorXBase as? Failure {
                result.append(match)
            }
        }

        return result
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextValues(
        for key: _ErrorContextBinding.Key
    ) -> [_ErrorContextBinding.Value] {
        context.compactMap {
            $0.key == key ? $0.value : nil
        }
    }

    public func projectedContext(
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> [_ErrorContextBinding] {
        context.compactMap {
            $0.projected(using: policy)
        }
    }

    public func projectedFailureContextOccurrences(
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> [FailureContextOccurrence] {
        failureContextOccurrences.compactMap { occurrence in
            guard let context = occurrence.context.projected(using: policy) else {
                return nil
            }

            return FailureContextOccurrence(
                path: occurrence.path,
                relationRoles: occurrence.relationRoles,
                context: context
            )
        }
    }

    public func projectedContextValues(
        for key: _ErrorContextBinding.Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> [_ErrorContextBinding.Value] {
        projectedContext(using: policy).compactMap {
            $0.key == key ? $0.value : nil
        }
    }

    public func projectedContextValues<Key: _ErrorOccurrenceContextKey>(
        for key: Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> [_ErrorContextBinding.Value] {
        projectedContextValues(for: .init(key), using: policy)
    }

    public func projectedContextValue(
        for key: _ErrorContextBinding.Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> _ErrorContextBinding.Value? {
        projectedContextValues(for: key, using: policy).first
    }

    public func projectedContextValue<Key: _ErrorOccurrenceContextKey>(
        for key: Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> _ErrorContextBinding.Value? {
        projectedContextValue(for: .init(key), using: policy)
    }

    public func projectedContextString(
        for key: _ErrorContextBinding.Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> String? {
        projectedContextValue(for: key, using: policy)?.stringValue
    }

    public func projectedContextString<Key: _ErrorOccurrenceContextKey>(
        for key: Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> String? {
        projectedContextValue(for: key, using: policy)?.stringValue
    }

    public func projectedContextInt(
        for key: _ErrorContextBinding.Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> Int? {
        projectedContextValue(for: key, using: policy)?.intValue
    }

    public func projectedContextInt<Key: _ErrorOccurrenceContextKey>(
        for key: Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> Int? {
        projectedContextValue(for: key, using: policy)?.intValue
    }

    public func projectedContextBool(
        for key: _ErrorContextBinding.Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> Bool? {
        projectedContextValue(for: key, using: policy)?.boolValue
    }

    public func projectedContextBool<Key: _ErrorOccurrenceContextKey>(
        for key: Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> Bool? {
        projectedContextValue(for: key, using: policy)?.boolValue
    }

    public func projectedContextDouble(
        for key: _ErrorContextBinding.Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> Double? {
        projectedContextValue(for: key, using: policy)?.doubleValue
    }

    public func projectedContextDouble<Key: _ErrorOccurrenceContextKey>(
        for key: Key,
        using policy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> Double? {
        projectedContextValue(for: key, using: policy)?.doubleValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextValues<Key: _ErrorOccurrenceContextKey>(
        for key: Key
    ) -> [_ErrorContextBinding.Value] {
        contextValues(for: .init(key))
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextValue(
        for key: _ErrorContextBinding.Key
    ) -> _ErrorContextBinding.Value? {
        contextValues(for: key).first
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextValue<Key: _ErrorOccurrenceContextKey>(
        for key: Key
    ) -> _ErrorContextBinding.Value? {
        contextValue(for: .init(key))
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextString(
        for key: _ErrorContextBinding.Key
    ) -> String? {
        contextValue(for: key)?.stringValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextString<Key: _ErrorOccurrenceContextKey>(
        for key: Key
    ) -> String? {
        contextValue(for: key)?.stringValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextInt(
        for key: _ErrorContextBinding.Key
    ) -> Int? {
        contextValue(for: key)?.intValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextInt<Key: _ErrorOccurrenceContextKey>(
        for key: Key
    ) -> Int? {
        contextValue(for: key)?.intValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextBool(
        for key: _ErrorContextBinding.Key
    ) -> Bool? {
        contextValue(for: key)?.boolValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextBool<Key: _ErrorOccurrenceContextKey>(
        for key: Key
    ) -> Bool? {
        contextValue(for: key)?.boolValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextDouble(
        for key: _ErrorContextBinding.Key
    ) -> Double? {
        contextValue(for: key)?.doubleValue
    }

    /// Returns raw in-process context. Use projected accessors for display/export.
    public func contextDouble<Key: _ErrorOccurrenceContextKey>(
        for key: Key
    ) -> Double? {
        contextValue(for: key)?.doubleValue
    }

    public func containsContextValue(
        _ value: _ErrorContextBinding.Value,
        for key: _ErrorContextBinding.Key
    ) -> Bool {
        contextValues(for: key).contains(value)
    }

    public func containsContextValue<Key: _ErrorOccurrenceContextKey>(
        _ value: _ErrorContextBinding.Value,
        for key: Key
    ) -> Bool {
        containsContextValue(value, for: .init(key))
    }

    fileprivate static func _failureTree(
        for error: any Swift.Error,
        chain: _ErrorChain
    ) -> _ErrorFailureTree {
        let base = error._errorXBase

        if let error = base as? any _ErrorFailureTreeRepresentable {
            return error.errorFailureTree
        }

        if let failureTree = (base as? any _ErrorDescribed)?._errorDescriptorCase?.failureTree {
            return failureTree
        }

        if let error = base as? any _ErrorRelatedFailuresRepresentable {
            return .relation(
                .init(
                    role: .contains,
                    children: [.error(AnyError(erasing: base))] + error.relatedErrorFailures.map {
                        .relation($0)
                    }
                )
            )
        }

        return .init(chain: chain)
    }

    fileprivate static func _headlineIdentity(
        root: any Swift.Error,
        failureIdentityOccurrences: [FailureIdentityOccurrence]
    ) -> _ErrorIdentity? {
        if let identity = root._errorIdentity {
            return identity
        }

        if let identity = failureIdentityOccurrences.first(where: { occurrence in
            occurrence.relationRoles.contains(.primary)
        })?.identity {
            return identity
        }

        return failureIdentityOccurrences.first?.identity
    }

    fileprivate static func _identityOccurrences(
        in chain: _ErrorChain
    ) -> [IdentityOccurrence] {
        chain.elements.enumerated().compactMap { index, element in
            guard let identity = element.base._errorIdentity else {
                return nil
            }

            return IdentityOccurrence(
                chainIndex: index,
                error: element,
                identity: identity
            )
        }
    }

    fileprivate static func _failureIdentityOccurrences(
        in topology: _ErrorFailureTopology
    ) -> [FailureIdentityOccurrence] {
        topology.identityOccurrences().map(FailureIdentityOccurrence.init)
    }

    fileprivate static func _presentation(
        in chain: _ErrorChain,
        traits: _ErrorTraits
    ) -> _ErrorPresentation? {
        if let presentation = (chain.elements.first?.base._errorXBase as? any _ErrorDescribed)?._errorDescriptorCase?.presentation {
            return presentation
        }

        if let presentation = (chain.elements.first?.base._errorXBase as? any _ErrorPresentationRepresentable)?.errorPresentation {
            return presentation
        }

        if let presentation = traits.first(of: _ErrorPresentationTrait.self)?.presentation {
            return presentation
        }

        for element in chain.elements.dropFirst() {
            if let presentation = (element.base._errorXBase as? any _ErrorDescribed)?._errorDescriptorCase?.presentation {
                return presentation
            }

            if let presentation = (element.base._errorXBase as? any _ErrorPresentationRepresentable)?.errorPresentation {
                return presentation
            }
        }

        for element in chain.elements {
            let error = element.base._errorXBase

            if let error = error as? LocalizedError {
                return _ErrorPresentation(
                    summary: error.errorDescription,
                    reason: error.failureReason,
                    helpAnchor: error.helpAnchor
                )
            }
        }

        return nil
    }

    fileprivate static func _recoverySuggestions(
        in chain: _ErrorChain,
        traits: _ErrorTraits
    ) -> [_ErrorRecoverySuggestion] {
        var result = traits
            .all(of: _ErrorRecoveryTrait.self)
            .flatMap(\.suggestions)

        for element in chain.elements {
            let error = element.base._errorXBase

            if let descriptorCase = (error as? any _ErrorDescribed)?._errorDescriptorCase {
                result.append(contentsOf: descriptorCase.recoverySuggestions)
            }

            if let error = error as? any _ErrorRecoveryRepresentable {
                result.append(contentsOf: error.errorRecoverySuggestions)
            } else if let error = error as? RecoverableError {
                result.append(
                    contentsOf: error.recoveryOptions.map {
                        _ErrorRecoverySuggestion(title: $0)
                    }
                )
            } else if let error = error as? LocalizedError, let recoverySuggestion = error.recoverySuggestion {
                result.append(_ErrorRecoverySuggestion(title: recoverySuggestion))
            }
        }

        return result
    }

    fileprivate static func _context(
        in topology: _ErrorFailureTopology,
        traits: _ErrorTraits,
        observation: _ErrorObservationContext
    ) -> [_ErrorContextBinding] {
        var result = traits
            .all(of: _ErrorContextTrait.self)
            .flatMap(\.bindings)

        result.append(contentsOf: topology.contextBindings())
        result.append(contentsOf: observation.contextBindings)

        return result
    }
}

extension _ErrorFailureTree {
    fileprivate func _errorXForEachError(
        _ body: (AnyError) -> Void
    ) {
        switch self {
            case .error(let error):
                body(error)
            case .relation(let relation):
                for child in relation.children {
                    child._errorXForEachError(body)
                }
        }
    }
}

extension _ErrorReport.FailureIdentityOccurrence {
    fileprivate init(
        _ occurrence: _ErrorFailureTopology.IdentityOccurrence
    ) {
        self.init(
            path: occurrence.path.indices,
            relationRoles: occurrence.relationRoles,
            error: occurrence.error,
            identity: occurrence.identity
        )
    }
}

extension _ErrorReport.FailureContextOccurrence {
    fileprivate init(
        _ occurrence: _ErrorFailureTopology.ContextOccurrence
    ) {
        self.init(
            path: occurrence.path.indices,
            relationRoles: occurrence.relationRoles,
            context: occurrence.context
        )
    }
}
