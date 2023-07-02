//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension _PlatformSubsystemDomains.Networking {
    public enum Error: _SubsystemDomainError {
        case notConnectedToInternet
        case serverUnreachable
        case connectionLost
        case requestTimedOut
        case invalidServerResponse
        case failedToDecodeResponse
        case networkFrameworkError(AnyError)
        
        public init(_catchAll error: AnyError) {
            self = .networkFrameworkError(error)
        }
    }
}

extension _PlatformSubsystemDomains.Networking.Error: LocalizedError {
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
}
