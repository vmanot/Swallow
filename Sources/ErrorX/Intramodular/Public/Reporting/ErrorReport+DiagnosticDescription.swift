//
// Copyright (c) Vatsal Manot
//

extension ErrorReport {
  /// The amount of detail included in a diagnostic description.
  public enum DiagnosticStyle: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// A single-line description of the primary failure.
    case compact

    /// A multiline description including recovery, context, and causality.
    case detailed

    public var description: String {
      switch self {
      case .compact:
        return "compact"
      case .detailed:
        return "detailed"
      }
    }

    public var debugDescription: String {
      ".\(description)"
    }
  }
}

extension ErrorReport: CustomStringConvertible, CustomDebugStringConvertible {
  /// A compact diagnostic description of the report.
  public var description: String {
    diagnosticDescription()
  }

  /// A detailed, privacy-preserving description of the report.
  public var debugDescription: String {
    diagnosticDescription(style: .detailed, contextProjection: .publicOnly)
  }
}

extension ErrorReport {
  /// Returns a human-readable description suitable for diagnostics and logs.
  public func diagnosticDescription(
    style: DiagnosticStyle = .compact,
    contextProjection: ErrorContext.Projection = .publicOnly
  ) -> String {
    switch style {
    case .compact:
      return _compactTextDescription(contextProjection: contextProjection)
    case .detailed:
      return _detailedTextDescriptionLines(contextProjection: contextProjection)
        .joined(separator: "\n")
    }
  }
}

extension Error {
  /// Renders this error after observing it with the supplied boundary facts.
  public func diagnosticDescription(
    observation: ErrorObservation = .current,
    style: ErrorReport.DiagnosticStyle = .compact,
    contextProjection: ErrorContext.Projection = .publicOnly
  ) -> String {
    ErrorReport(self as any Swift.Error, observation: observation)
      .diagnosticDescription(
        style: style,
        contextProjection: contextProjection
      )
  }
}

extension ErrorReport {
  fileprivate func _compactTextDescription(
    contextProjection: ErrorContext.Projection
  ) -> String {
    var components: [String] = []

    if let primaryIdentity {
      components.append("[\(primaryIdentity.description)]")
    }

    let primaryDescription = _primaryTextDescription(contextProjection: contextProjection)

    if primaryDescription != primaryIdentity?.description {
      components.append(primaryDescription)
    }

    return components.joined(separator: " ")
  }

  fileprivate func _detailedTextDescriptionLines(
    contextProjection: ErrorContext.Projection
  ) -> [String] {
    var lines: [String] = [_compactTextDescription(contextProjection: contextProjection)]

    if let failureReason = presentation?.failureReason, !failureReason.isEmpty {
      lines.append("Reason: \(failureReason)")
    }

    if let diagnosticDescription = presentation?.diagnosticDescription,
      !diagnosticDescription.isEmpty
    {
      lines.append("Debug: \(diagnosticDescription)")
    }

    if let helpAnchor = presentation?.helpAnchor, !helpAnchor.isEmpty {
      lines.append("Help: \(helpAnchor)")
    }

    if let scenario = observation.scenario {
      lines.append("Scenario: \(scenario.identifier)")
    }

    if !recoveryOptions.isEmpty {
      lines.append("Recovery:")
      lines.append(
        contentsOf: recoveryOptions.map { option in
          if let explanation = option.explanation, !explanation.isEmpty {
            return "- \(option.title): \(explanation)"
          } else {
            return "- \(option.title)"
          }
        })
    }

    let projectedContext = context.projected(using: contextProjection)

    if !projectedContext.isEmpty {
      lines.append("Context:")
      lines.append(
        contentsOf: projectedContext.map { entry in
          "- \(entry.key.name): \(entry.value.description)"
        })
    }

    if causeChain.count > 1 {
      lines.append("Cause chain:")
      lines.append(
        contentsOf: causeChain.enumerated().map { index, cause in
          let error = cause._errorXBase
          var components: [String] = [
            "\(index + 1).",
            String(reflecting: Swift.type(of: error)),
          ]

          if let identity = error._errorXIdentity {
            components.append("[\(identity.description)]")
          }

          return components.joined(separator: " ")
        })
    }

    if errorTree._containsNonPrimaryRelation
      || identityOccurrences.map(\.identity) != causeIdentities
    {
      lines.append("Error tree:")
      lines.append(
        contentsOf: errorTree._diagnosticDescriptionLines(
          contextOccurrences: contextOccurrences(projectedUsing: contextProjection)
        )
      )
    }

    return lines
  }

  fileprivate func _primaryTextDescription(
    contextProjection: ErrorContext.Projection
  ) -> String {
    if let message = presentation?.message, !message.isEmpty {
      return message
    }

    if let primaryIdentity {
      return primaryIdentity.description
    }

    if contextProjection.visibility == .diagnostic {
      return String(describing: error._errorXBase)
    }

    return String(reflecting: Swift.type(of: error._errorXBase))
  }
}

extension ErrorTree {
  fileprivate var _containsNonPrimaryRelation: Bool {
    var pending: [Self] = [self]

    while let tree = pending.popLast() {
      let primaryRelations = tree.relations.filter {
        $0.kind == .cause || $0.kind == .translatedFrom
      }

      guard primaryRelations.count == tree.relations.count,
        primaryRelations.count <= 1
      else {
        return true
      }

      if let primaryRelation = primaryRelations.first {
        pending.append(primaryRelation.subtree)
      }
    }

    return false
  }

  fileprivate func _diagnosticDescriptionLines(
    contextOccurrences: [ErrorReport.ContextOccurrence] = []
  ) -> [String] {
    typealias PendingNode = (
      tree: ErrorTree,
      indentation: String,
      path: [Int],
      relationPath: [ErrorRelation.Kind],
      incomingRelation: ErrorRelation?
    )

    var pending: [PendingNode] = [(self, "", [], [], nil)]
    var result: [String] = []

    while let node = pending.popLast() {
      var errorIndentation = node.indentation

      if let relation = node.incomingRelation {
        result.append("\(node.indentation)- \(relation.kind.description)")
        result.append(
          contentsOf: _diagnosticContextLines(
            indentation: node.indentation,
            path: node.path,
            relationPath: node.relationPath,
            owner: .relation,
            contextOccurrences: contextOccurrences
          )
        )

        errorIndentation += "  "
      }

      let base = node.tree.root._errorXBase
      var line = "\(errorIndentation)- \(String(reflecting: Swift.type(of: base)))"

      if let identity = base._errorXIdentity {
        line += " [\(identity.description)]"
      }

      result.append(line)
      result.append(
        contentsOf: _diagnosticContextLines(
          indentation: errorIndentation,
          path: node.path,
          relationPath: node.relationPath,
          owner: .error,
          contextOccurrences: contextOccurrences
        )
      )

      for index in node.tree.relations.indices.reversed() {
        let relation = node.tree.relations[index]

        pending.append(
          (
            tree: relation.subtree,
            indentation: errorIndentation + "  ",
            path: node.path + [index],
            relationPath: node.relationPath + [relation.kind],
            incomingRelation: relation
          )
        )
      }
    }

    return result
  }

  private func _diagnosticContextLines(
    indentation: String,
    path: [Int],
    relationPath: [ErrorRelation.Kind],
    owner: ErrorReport.ContextOccurrence.Owner,
    contextOccurrences: [ErrorReport.ContextOccurrence]
  ) -> [String] {
    let matchingContext = contextOccurrences.filter {
      $0.path == path && $0.relationPath == relationPath && $0.owner == owner
    }

    guard !matchingContext.isEmpty else {
      return []
    }

    return ["\(indentation)  context:"]
      + matchingContext.map { occurrence in
        "\(indentation)    \(occurrence.entry.key.name): \(occurrence.entry.value.description)"
      }
  }
}
