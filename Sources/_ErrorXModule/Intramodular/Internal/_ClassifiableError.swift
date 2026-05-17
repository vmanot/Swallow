//
// Copyright (c) Vatsal Manot
//

import Swallow

@available(
    *,
    deprecated,
    message: "Use explicit error identity, occurrence context, and report-time policy instead. Coarse built-in classification is too weak for _ErrorX's model."
)
/// Legacy error classification surface.
///
/// Classification is not stable identity, occurrence context, severity, or
/// presentation. Keeping this deprecated avoids silently blessing a broad,
/// closed-ish taxonomy before the report/projection layers have earned it.
public protocol _ClassifiableError {
    associatedtype Classification: _ElementGrouping where Classification.Element: _ErrorClassificationProtocol

    var errorClassification: Classification { get }
}

@available(
    *,
    deprecated,
    message: "Use explicit error identity, occurrence context, and report-time policy instead."
)
/// Legacy marker protocol for coarse classification values.
public protocol _ErrorClassificationProtocol {

}

@available(
    *,
    deprecated,
    message: "This taxonomy is intentionally deprecated. Model stable error identity and typed context instead."
)
/// Legacy broad classification buckets.
public enum _GeneralErrorClassification: String, _ErrorClassificationProtocol {
    case network
    case database
    case fileSystem
    case authorization
    case validation
    case serialization
    case userInterface
    case concurrent
    case resource
    case thirdPartyLibrary
    case hardware
    case operatingSystem
    case security
    case payment
    case analytics
    case communication
    case configuration
    case stateManagement
    case internationalization
    case deprecation
    case performance
    case testing
    case unsupportedFeature
    case interoperability
    case documentation
}
