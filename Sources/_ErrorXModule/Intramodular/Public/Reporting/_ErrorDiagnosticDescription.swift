//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Human-readable diagnostic projection of an `_ErrorReport`.
public struct _ErrorDiagnosticDescription: Hashable, Sendable, CustomStringConvertible {
    /// Report rendering verbosity.
    public enum DetailLevel: Hashable, Sendable {
        case compact
        case detailed
    }

    public var lines: [String]

    public var description: String {
        lines.joined(separator: "\n")
    }

    public init(lines: [String]) {
        self.lines = lines
    }
}

extension _ErrorReport {
    public func _diagnosticDescription(
        detailLevel: _ErrorDiagnosticDescription.DetailLevel = .compact,
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> _ErrorDiagnosticDescription {
        switch detailLevel {
            case .compact:
                return .init(lines: [_compactTextDescription()])
            case .detailed:
                return .init(lines: _detailedTextDescriptionLines(contextProjectionPolicy: contextProjectionPolicy))
        }
    }
}

extension Error {
    public func _diagnosticDescription(
        scenario: some _ErrorReportScenario,
        detailLevel: _ErrorDiagnosticDescription.DetailLevel = .compact,
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> String {
        _ErrorReporting.report(self as any Swift.Error, scenario: scenario)
            ._diagnosticDescription(
                detailLevel: detailLevel,
                contextProjectionPolicy: contextProjectionPolicy
            )
            .description
    }

    public func _diagnosticDescription(
        observation: _ErrorObservationContext = .init(),
        detailLevel: _ErrorDiagnosticDescription.DetailLevel = .compact,
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> String {
        _ErrorReporting.report(self as any Swift.Error, observation: observation)
            ._diagnosticDescription(
                detailLevel: detailLevel,
                contextProjectionPolicy: contextProjectionPolicy
            )
            .description
    }
}

extension _ErrorReport {
    fileprivate func _compactTextDescription() -> String {
        var components: [String] = []

        if let identity {
            components.append("[\(identity.description)]")
        }

        components.append(_primaryTextDescription)

        return components.joined(separator: " ")
    }

    fileprivate func _detailedTextDescriptionLines(
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy
    ) -> [String] {
        var lines: [String] = [_compactTextDescription()]

        if let reason = presentation?.reason, !reason.isEmpty {
            lines.append("Reason: \(reason)")
        }

        if let debugDescription = presentation?.debugDescription, !debugDescription.isEmpty {
            lines.append("Debug: \(debugDescription)")
        }

        if let helpAnchor = presentation?.helpAnchor, !helpAnchor.isEmpty {
            lines.append("Help: \(helpAnchor)")
        }

        if let scenario {
            lines.append("Scenario: \(scenario.stableIdentifier)")
        }

        if !recoverySuggestions.isEmpty {
            lines.append("Recovery:")
            lines.append(contentsOf: recoverySuggestions.map { suggestion in
                if let explanation = suggestion.explanation, !explanation.isEmpty {
                    return "- \(suggestion.title): \(explanation)"
                } else {
                    return "- \(suggestion.title)"
                }
            })
        }

        let projectedContext = projectedContext(using: contextProjectionPolicy)

        if !projectedContext.isEmpty {
            lines.append("Context:")
            lines.append(contentsOf: projectedContext.map { binding in
                "- \(binding.key.rawValue): \(binding.value.description)"
            })
        }

        if chain.elements.count > 1 {
            lines.append("Cause chain:")
            lines.append(contentsOf: chain.elements.enumerated().map { index, element in
                let error = element.base._errorXBase
                var components: [String] = [
                    "\(index + 1).",
                    String(reflecting: Swift.type(of: error))
                ]

                if let identity = error._errorIdentity {
                    components.append("[\(identity.description)]")
                }

                return components.joined(separator: " ")
            })
        }

        if failureTree._containsNonPrimaryRelation || failureIdentityOccurrences.count > identityOccurrences.count {
            lines.append("Failure tree:")
            lines.append(
                contentsOf: failureTree._diagnosticDescriptionLines(
                    contextOccurrences: projectedFailureContextOccurrences(using: contextProjectionPolicy)
                )
            )
        }

        return lines
    }

    fileprivate var _primaryTextDescription: String {
        if let summary = presentation?.summary, !summary.isEmpty {
            return summary
        }

        if let identity {
            return identity.description
        }

        return String(reflecting: Swift.type(of: root.base._errorXBase))
    }
}

extension _ErrorFailureTree {
    fileprivate var _containsNonPrimaryRelation: Bool {
        switch self {
            case .error:
                return false
            case .relation(let relation):
                return relation.role != .primary || relation.children.contains { child in
                    child._containsNonPrimaryRelation
                }
        }
    }

    fileprivate func _diagnosticDescriptionLines(
        indentation: String = "",
        path: [Int] = [],
        relationRoles: [_ErrorFailureRelationRole] = [],
        contextOccurrences: [_ErrorReport.FailureContextOccurrence] = []
    ) -> [String] {
        switch self {
            case .error(let error):
                let base = error.base._errorXBase
                var line = "\(indentation)- \(String(reflecting: Swift.type(of: base)))"

                if let identity = base._errorIdentity {
                    line += " [\(identity.description)]"
                }

                return [line] + _diagnosticContextLines(
                    indentation: indentation,
                    path: path,
                    relationRoles: relationRoles,
                    contextOccurrences: contextOccurrences
                )
            case .relation(let relation):
                let currentRelationRoles = relationRoles + [relation.role]
                var result = ["\(indentation)- \(relation.role.description)"]

                result.append(
                    contentsOf: _diagnosticContextLines(
                        indentation: indentation,
                        path: path,
                        relationRoles: currentRelationRoles,
                        contextOccurrences: contextOccurrences
                    )
                )

                for (index, child) in relation.children.enumerated() {
                    result.append(
                        contentsOf: child._diagnosticDescriptionLines(
                            indentation: indentation + "  ",
                            path: path + [index],
                            relationRoles: currentRelationRoles,
                            contextOccurrences: contextOccurrences
                        )
                    )
                }

                return result
        }
    }

    private func _diagnosticContextLines(
        indentation: String,
        path: [Int],
        relationRoles: [_ErrorFailureRelationRole],
        contextOccurrences: [_ErrorReport.FailureContextOccurrence]
    ) -> [String] {
        let matchingContext = contextOccurrences.filter {
            $0.path == path && $0.relationRoles == relationRoles
        }

        guard !matchingContext.isEmpty else {
            return []
        }

        return ["\(indentation)  context:"] + matchingContext.map { occurrence in
            "\(indentation)    \(occurrence.context.key.rawValue): \(occurrence.context.value.description)"
        }
    }
}
