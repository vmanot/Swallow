//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Stable error identity for an error occurrence.
///
/// Error values carry payload. Codes carry support/debugging identity. Keeping
/// the split explicit prevents enum shape, associated values, and prose from
/// becoming accidental API.
///
/// Prefer macro-generated codes from `@ErrorDomain`, `@ErrorCodeCatalog`, and
/// `@ErrorModel`. Manual conformances are the compatibility escape hatch.
public protocol _ErrorCode: _ErrorStableIdentifier {
    associatedtype Domain: _SubsystemDomain

    var domain: Domain { get }
}

extension _ErrorCode where Domain: Initiable {
    public var domain: Domain {
        Domain()
    }
}

/// Exportable domain/code identity for a modeled error.
public struct _ErrorIdentity: Hashable, Sendable, CustomStringConvertible, Identifiable {
    public var id: Self {
        self
    }

    public var domain: _SubsystemDomainIdentifier
    public var code: String

    public var description: String {
        "\(domain.rawValue).\(code)"
    }

    public init(
        domain: _SubsystemDomainIdentifier,
        code: String
    ) {
        self.domain = domain
        self.code = code
    }
}

/// Type-erased stable error code.
///
/// Production code should prefer macro-generated domains and catalogs.
public struct _AnyErrorCode: Hashable, Sendable, CustomStringConvertible, ValueConvertible {
    @_HashableExistential
    public private(set) var base: any _ErrorCode

    public var value: any _ErrorCode {
        base
    }

    public var domain: any _SubsystemDomain {
        base.domain
    }

    public var stableIdentifier: String {
        base.stableIdentifier
    }

    public var identity: _ErrorIdentity? {
        guard let domain = domain as? any _SubsystemDomainIdentifiable else {
            return nil
        }

        return _ErrorIdentity(
            domain: domain.subsystemDomainIdentifier,
            code: stableIdentifier
        )
    }

    public var description: String {
        stableIdentifier
    }

    public init<Code: _ErrorCode>(
        _ base: Code
    ) {
        self.base = base
    }
}

extension _AnyErrorCode: _UnwrappableHashableTypeEraser {
    public typealias _UnwrappedBaseType = any _ErrorCode

    public init(_erasing base: _UnwrappedBaseType) {
        self.base = base
    }

    public func _unwrapBase() -> _UnwrappedBaseType {
        base
    }
}

/// Manual fallback for errors that cannot use descriptor-generating macros.
public protocol _ErrorCodeRepresentable {
    associatedtype ErrorCode: _ErrorCode

    var errorCode: ErrorCode { get }
}

extension _ErrorCodeRepresentable {
    public var _opaqueErrorCode: _AnyErrorCode {
        _AnyErrorCode(errorCode)
    }
}

extension Error {
    public var _errorIdentity: _ErrorIdentity? {
        _errorXBase._explicitErrorIdentity
    }

    public var _errorCode: _AnyErrorCode? {
        _errorXBase._explicitErrorCode
    }
}

extension _ErrorIdentity {
    public init?(_ error: some Error) {
        guard let identity = error._errorIdentity else {
            return nil
        }

        self = identity
    }
}

extension Error {
    fileprivate var _explicitErrorCode: _AnyErrorCode? {
        if let code = (self as? any _ErrorDescribed)?._errorDescriptorCase?.code {
            return code
        }

        if let code = (self as? any _ErrorCodeRepresentable)?._opaqueErrorCode {
            return code
        }

        return nil
    }

    fileprivate var _explicitErrorIdentity: _ErrorIdentity? {
        if let identity = _explicitErrorCode?.identity {
            return identity
        }

        if let identity = (self as? any _ErrorX)?.traits.first(of: _ErrorIdentityTrait.self)?.identity {
            return identity
        }

        return nil
    }
}
