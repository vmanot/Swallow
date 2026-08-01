//
// Copyright (c) Vatsal Manot
//

import Foundation

/// A normalized, observation-time view of an error and its related failures.
public struct ErrorReport: Sendable {
  /// An identity found at a position in the complete error tree.
  public struct IdentityOccurrence: Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// Relation indices locating the error in the tree.
    public let path: [Int]

    /// The relationships traversed to reach the error.
    public let relationPath: [ErrorRelation.Kind]

    /// The error at this position.
    public let error: any Error

    /// The identity exposed by ``error``.
    public let identity: ErrorIdentity

    /// The identity and its relation-index path.
    public var description: String {
      "\(identity.description) at \(path)"
    }

    /// A structural description of the identity occurrence.
    public var debugDescription: String {
      "ErrorReport.IdentityOccurrence(path: \(path), relationPath: \(relationPath.map(\.debugDescription)), errorType: \(String(reflecting: Swift.type(of: error))), identity: \(identity.debugDescription))"
    }
  }

  /// A context entry found at a position in the complete error tree.
  public struct ContextOccurrence: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// The tree element that owns a context entry.
    public enum Owner: Hashable, Sendable, CustomStringConvertible,
      CustomDebugStringConvertible
    {
      /// The context belongs to an error node.
      case error

      /// The context belongs to the incoming relationship.
      case relation

      public var description: String {
        switch self {
        case .error:
          return "error"
        case .relation:
          return "relation"
        }
      }

      public var debugDescription: String {
        ".\(description)"
      }
    }

    /// Relation indices locating the entry's owner in the tree.
    public let path: [Int]

    /// The relationships traversed to reach the entry.
    public let relationPath: [ErrorRelation.Kind]

    /// Whether the context belongs to an error or a relationship.
    public let owner: Owner

    /// The context entry at this position.
    public let entry: ErrorContext.Entry

    /// The privacy-preserving entry and its relation-index path.
    public var description: String {
      "\(entry.description) at \(path)"
    }

    /// A privacy-preserving structural description of the context occurrence.
    public var debugDescription: String {
      "ErrorReport.ContextOccurrence(path: \(path), relationPath: \(relationPath.map(\.debugDescription)), owner: \(owner.debugDescription), entry: \(entry.debugDescription))"
    }
  }

  /// The observed error after removing transparent wrappers.
  public let error: any Error

  /// The primary cause chain, beginning with the observed error.
  public let causeChain: ErrorCauseChain

  /// The complete composition of the observed error and related failures.
  public let errorTree: ErrorTree

  /// The identity of the primary failure, when one is available.
  public let primaryIdentity: ErrorIdentity?

  /// Identified errors and their positions in the complete error tree.
  public let identityOccurrences: [IdentityOccurrence]

  /// Context entries and their positions in the complete error tree.
  public let contextOccurrences: [ContextOccurrence]

  /// The first authored or system presentation in the primary cause chain.
  public let presentation: ErrorPresentation?

  /// Recovery options collected from the primary cause chain.
  public let recoveryOptions: [ErrorRecoveryOption]

  /// Error-tree context followed by observation-time context.
  public let context: ErrorContext

  /// The facts supplied at the observation boundary.
  public let observation: ErrorObservation

  /// Creates a report by observing `error` with the supplied boundary facts.
  public init(
    _ error: any Swift.Error,
    observation: ErrorObservation = .current
  ) {
    self.init(error, observation: observation, errorTree: nil)
  }

  init(
    _ error: any Swift.Error,
    observation: ErrorObservation,
    errorTree explicitErrorTree: ErrorTree?
  ) {
    let errorTree =
      explicitErrorTree
      ?? ErrorTree._errorXDiscovering(error)
    let causeChain = ErrorCauseChain(errorTree: errorTree)
    let occurrences = errorTree._errorXOccurrences()
    let identityOccurrences = occurrences.identities.map(Self.IdentityOccurrence.init)
    let contextOccurrences = occurrences.contexts.map(Self.ContextOccurrence.init)

    self.error = errorTree.root
    self.causeChain = causeChain
    self.errorTree = errorTree
    self.primaryIdentity = Self._primaryIdentity(
      in: causeChain,
      occurrences: identityOccurrences
    )
    self.identityOccurrences = identityOccurrences
    self.contextOccurrences = contextOccurrences
    self.presentation = Self._presentation(in: causeChain)
    self.recoveryOptions = Self._recoveryOptions(in: causeChain)
    self.context = Self._context(
      contextOccurrences: contextOccurrences,
      observation: observation
    )
    self.observation = observation
  }
}

extension ErrorReport {
  /// The identities in the primary cause chain, ordered outermost first.
  public var causeIdentities: [ErrorIdentity] {
    causeChain.compactMap(\._errorXIdentity)
  }

  /// Every identity in depth-first error-tree order.
  public var identities: [ErrorIdentity] {
    identityOccurrences.map(\.identity)
  }

  /// Returns whether the error tree contains `identity`.
  public func contains(_ identity: ErrorIdentity) -> Bool {
    identityOccurrences.contains { $0.identity == identity }
  }

  /// Returns identities beneath a relation of `kind`.
  public func identities(relatedBy kind: ErrorRelation.Kind) -> [ErrorIdentity] {
    identityOccurrences.compactMap { occurrence in
      occurrence.relationPath.contains(kind) ? occurrence.identity : nil
    }
  }

  /// Returns context occurrences beneath a relation of `kind`.
  public func contextOccurrences(
    relatedBy kind: ErrorRelation.Kind
  ) -> [ContextOccurrence] {
    contextOccurrences.filter { $0.relationPath.contains(kind) }
  }

  /// Returns occurrences whose entries are visible under `projection`.
  public func contextOccurrences(
    projectedUsing projection: ErrorContext.Projection
  ) -> [ContextOccurrence] {
    contextOccurrences.compactMap { occurrence in
      guard let entry = occurrence.entry.projected(using: projection) else {
        return nil
      }

      return ContextOccurrence(
        path: occurrence.path,
        relationPath: occurrence.relationPath,
        owner: occurrence.owner,
        entry: entry
      )
    }
  }

  /// Returns all matching errors in depth-first error-tree order.
  public func errors<Failure: Error>(
    of type: Failure.Type
  ) -> [Failure] {
    var result: [Failure] = []

    errorTree._errorXForEachError { error in
      if let match = error._errorXBase._errorXCast(to: type) {
        result.append(match)
      }
    }

    return result
  }

  /// Returns the first matching error in depth-first error-tree order.
  public func firstError<Failure: Error>(
    of type: Failure.Type
  ) -> Failure? {
    errorTree._errorXFirstError(of: type)
  }

  /// Returns whether the error tree contains an error of `type`.
  public func contains<Failure: Error>(
    _ type: Failure.Type
  ) -> Bool {
    firstError(of: type) != nil
  }
}

extension ErrorReport {
  fileprivate static func _primaryIdentity(
    in causeChain: ErrorCauseChain,
    occurrences: [IdentityOccurrence]
  ) -> ErrorIdentity? {
    for error in causeChain {
      if let identity = error._errorXIdentity {
        return identity
      }
    }

    return occurrences.first?.identity
  }

  static func _presentation(
    in causeChain: ErrorCauseChain
  ) -> ErrorPresentation? {
    for cause in causeChain {
      let error = cause._errorXBase

      if let presentation = (error as? any _ModeledError)?._resolvedErrorDescriptor?.presentation,
        !presentation._isEmpty
      {
        return presentation
      }

      if let presentation = (error as? any ErrorPresentationProviding)?.errorPresentation,
        !presentation._isEmpty
      {
        return presentation
      }
    }

    for cause in causeChain {
      let error = cause._errorXBase

      if let localizedError = error as? LocalizedError {
        let presentation = ErrorPresentation(
          message: localizedError.errorDescription,
          failureReason: localizedError.failureReason,
          helpAnchor: localizedError.helpAnchor
        )

        if !presentation._isEmpty {
          return presentation
        }
      }

      if let presentation = _cocoaPresentation(for: error) {
        return presentation
      }
    }

    return nil
  }

  static func _recoveryOptions(
    in causeChain: ErrorCauseChain
  ) -> [ErrorRecoveryOption] {
    var result: [ErrorRecoveryOption] = []

    for cause in causeChain {
      let error = cause._errorXBase

      if let options = (error as? any _ModeledError)?._resolvedErrorDescriptor?.recoveryOptions,
        !options.isEmpty
      {
        result.append(contentsOf: options)
      } else if let options = (error as? any ErrorRecoveryProviding)?.errorRecoveryOptions,
        !options.isEmpty
      {
        result.append(contentsOf: options)
      } else if let recoverableError = error as? RecoverableError,
        !recoverableError.recoveryOptions.isEmpty
      {
        let explanation = (error as? LocalizedError)?.recoverySuggestion

        result.append(
          contentsOf: recoverableError.recoveryOptions.map {
            ErrorRecoveryOption(title: $0, explanation: explanation)
          }
        )
      } else if let localizedError = error as? LocalizedError,
        let suggestion = localizedError.recoverySuggestion
      {
        result.append(ErrorRecoveryOption(title: suggestion))
      } else {
        result.append(contentsOf: _cocoaRecoveryOptions(for: error))
      }
    }

    return result
  }

  fileprivate static func _cocoaPresentation(
    for error: any Swift.Error
  ) -> ErrorPresentation? {
    guard let userInfo = error._errorXCocoaUserInfo else {
      return nil
    }

    let presentation = ErrorPresentation(
      message: userInfo[NSLocalizedDescriptionKey] as? String
        ?? error._errorXNativeNSError?.localizedDescription,
      failureReason: userInfo[NSLocalizedFailureReasonErrorKey] as? String,
      diagnosticDescription: userInfo[NSDebugDescriptionErrorKey] as? String,
      helpAnchor: userInfo[NSHelpAnchorErrorKey] as? String
    )

    return presentation._isEmpty ? nil : presentation
  }

  fileprivate static func _cocoaRecoveryOptions(
    for error: any Swift.Error
  ) -> [ErrorRecoveryOption] {
    guard let userInfo = error._errorXCocoaUserInfo else {
      return []
    }

    let explanation = userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String

    if let options = userInfo[NSLocalizedRecoveryOptionsErrorKey] as? [String],
      !options.isEmpty
    {
      return options.map {
        ErrorRecoveryOption(title: $0, explanation: explanation)
      }
    }

    return explanation.map { [ErrorRecoveryOption(title: $0)] } ?? []
  }

  fileprivate static func _context(
    contextOccurrences: [ContextOccurrence],
    observation: ErrorObservation
  ) -> ErrorContext {
    var result = ErrorContext(contextOccurrences.map(\.entry))
    result.append(contentsOf: observation.context)

    return result
  }
}

extension ErrorPresentation {
  fileprivate var _isEmpty: Bool {
    message?.isEmpty != false
      && failureReason?.isEmpty != false
      && diagnosticDescription?.isEmpty != false
      && helpAnchor?.isEmpty != false
  }
}

extension ErrorTree {
  fileprivate func _errorXForEachError(
    _ body: (any Error) -> Void
  ) {
    var pending: [Self] = [self]

    while let tree = pending.popLast() {
      body(tree.root)
      pending.append(contentsOf: tree.relations.lazy.reversed().map(\.subtree))
    }
  }

  fileprivate func _errorXFirstError<Failure: Error>(
    of type: Failure.Type
  ) -> Failure? {
    var pending: [Self] = [self]

    while let tree = pending.popLast() {
      if let match = tree.root._errorXBase._errorXCast(to: type) {
        return match
      }

      pending.append(contentsOf: tree.relations.lazy.reversed().map(\.subtree))
    }

    return nil
  }
}

extension ErrorReport.IdentityOccurrence {
  fileprivate init(_ occurrence: _ErrorTreeOccurrences.Identity) {
    self.init(
      path: occurrence.path,
      relationPath: occurrence.relationPath,
      error: occurrence.error,
      identity: occurrence.identity
    )
  }
}

extension ErrorReport.ContextOccurrence {
  fileprivate init(_ occurrence: _ErrorTreeOccurrences.Context) {
    let owner: Owner

    switch occurrence.owner {
    case .error:
      owner = .error
    case .relation:
      owner = .relation
    }

    self.init(
      path: occurrence.path,
      relationPath: occurrence.relationPath,
      owner: owner,
      entry: occurrence.entry
    )
  }
}
