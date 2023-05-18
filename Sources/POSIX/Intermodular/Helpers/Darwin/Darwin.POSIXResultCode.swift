//
// Copyright (c) Vatsal Manot
//

import Foundation
import Darwin
import Swallow

public enum POSIXResultCode {
    case success
    case failure
    case error(POSIXErrorCode)
}

extension POSIXResultCode {
    public init(_ error: POSIXError) {
        self = .error(error.code)
    }

    public init(_ errorCode: POSIXErrorCode) {
        self = .error(errorCode)
    }
}

// MARK: - Extensions

extension POSIXResultCode {
    public func promoteToError() -> Error? {
        switch self {
        case .failure:
            return POSIXError.last
        case .error(let value):
            return POSIXError(value)

        default:
            return nil
        }
    }

    public func throwIfNecessary() throws {
        if let error = promoteToError() {
            throw error
        }
    }
}

// MARK: - Conformances

extension POSIXResultCode: RawRepresentable {
    public typealias RawValue = Int32

    public var rawValue: RawValue {
        switch self {
        case .success:
            return 0
        case .failure:
            return -1
        case .error(let value):
            return value.rawValue
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case Self.success.rawValue:
            self = .success
        case Self.failure.rawValue:
            self = .failure

        default: do {
            guard let code = POSIXErrorCode(rawValue: rawValue) else {
                return nil
            }

            self = .error(code)
            }
        }
    }
}

// MARK: - Helpers

extension Optional {
    public func toPOSIXResult() -> Result<Wrapped, POSIXError>! {
        return map({ .success($0) }) ?? POSIXError(promoting: .failure).map({ .failure($0) })
    }
}

extension POSIXError {
    public init?(promoting code: POSIXResultCode) {
        switch code {
        case .failure:
            self = .last
        case .error(let value):
            self = .init(value)

        default:
            return nil
        }
    }
}
