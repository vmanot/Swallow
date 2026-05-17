//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Marker for legacy Swallow-owned built-in subsystem domains.
public protocol _PlatformSubsystemDomain: _StaticInstance, _SubsystemDomain {

}

/// Namespace for Swallow-owned seed domains.
///
/// Client packages should usually define their own domain under the error type
/// they are modeling. These domains are compatibility scaffolding, not a
/// canonical list of ways software can fail.
@available(
    *,
    deprecated,
    message: "Define package-local domains with @ErrorDomain and @ErrorCodeCatalog instead."
)
public enum _PlatformSubsystemDomains {
    /// Swallow-authored filesystem failures.
    public struct Filesystem: _PlatformSubsystemDomain, _SubsystemDomainIdentifiable {
        public var subsystemDomainIdentifier: _SubsystemDomainIdentifier {
            "dev.vmanot.swallow.filesystem"
        }

        public init() {

        }
    }

    /// Swallow-authored networking failures.
    public struct Networking: _PlatformSubsystemDomain, _SubsystemDomainIdentifiable {
        public var subsystemDomainIdentifier: _SubsystemDomainIdentifier {
            "dev.vmanot.swallow.networking"
        }

        public init() {

        }

        /// Legacy Swallow networking failure vocabulary.
        public enum Error: _SubsystemDomainError, _ErrorCodeRepresentable, _ErrorCauseRepresentable, LocalizedError {
            /// Stable networking failure codes.
            public enum Code: String, _ErrorCode {
                case notConnectedToInternet = "notConnectedToInternet"
                case serverUnreachable = "serverUnreachable"
                case connectionLost = "connectionLost"
                case requestTimedOut = "requestTimedOut"
                case invalidServerResponse = "invalidServerResponse"
                case failedToDecodeResponse = "failedToDecodeResponse"
                case networkFrameworkError = "networkFrameworkError"

                public typealias Domain = _PlatformSubsystemDomains.Networking
            }

            case notConnectedToInternet
            case serverUnreachable
            case connectionLost
            case requestTimedOut
            case invalidServerResponse
            case failedToDecodeResponse
            case networkFrameworkError(AnyError)

            public var errorCode: Code {
                switch self {
                    case .notConnectedToInternet:
                        return .notConnectedToInternet
                    case .serverUnreachable:
                        return .serverUnreachable
                    case .connectionLost:
                        return .connectionLost
                    case .requestTimedOut:
                        return .requestTimedOut
                    case .invalidServerResponse:
                        return .invalidServerResponse
                    case .failedToDecodeResponse:
                        return .failedToDecodeResponse
                    case .networkFrameworkError:
                        return .networkFrameworkError
                }
            }

            public var underlyingError: (any Swift.Error)? {
                switch self {
                    case .networkFrameworkError(let error):
                        return error.base
                    default:
                        return nil
                }
            }

            public var errorDescription: String? {
                switch self {
                    case .notConnectedToInternet:
                        return NSLocalizedString(
                            "You are not connected to the internet. Please check your connection.",
                            comment: "Not Connected To Internet"
                        )
                    case .serverUnreachable:
                        return NSLocalizedString(
                            "The server is currently unreachable. Please try again later.",
                            comment: "Server Unreachable"
                        )
                    case .connectionLost:
                        return NSLocalizedString(
                            "Your connection was lost. Please check your internet connection.",
                            comment: "Connection Lost"
                        )
                    case .requestTimedOut:
                        return NSLocalizedString(
                            "Your request timed out. Please try again.",
                            comment: "Request Timed Out"
                        )
                    case .invalidServerResponse:
                        return NSLocalizedString(
                            "Received an invalid response from the server. Please try again later.",
                            comment: "Invalid Server Response"
                        )
                    case .failedToDecodeResponse:
                        return NSLocalizedString(
                            "There was an issue processing the response from the server. Please try again.",
                            comment: "Failed To Decode Response"
                        )
                    case .networkFrameworkError(let error):
                        return NSLocalizedString(
                            "A network error occurred: \(error.localizedDescription)",
                            comment: "Network Framework Error"
                        )
                }
            }

            public init(_catchAll error: AnyError) {
                self = .networkFrameworkError(error)
            }
        }

        public typealias ErrorCode = Error.Code
    }
}
