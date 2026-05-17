//
// Copyright (c) Vatsal Manot
//

/// Runtime surface for a declared catalog of stable error codes.
public protocol _ErrorCodeCatalogProtocol {
    static var allErrorCodes: [_AnyErrorCode] { get }
    static var errorCodeCatalogDescriptor: _ErrorCodeCatalogDescriptor { get }
}

extension _ErrorCodeCatalogProtocol {
    public static var errorCodeCatalogDescriptor: _ErrorCodeCatalogDescriptor {
        _ErrorCodeCatalogDescriptor(
            catalogIdentifier: String(reflecting: Self.self),
            entries: allErrorCodes.enumerated().map { offset, code in
                _ErrorCodeCatalogEntry(
                    stableIdentifier: code.stableIdentifier,
                    integerCode: offset + 1,
                    identity: code.identity
                )
            }
        )
    }

    public static func integerCode(
        for code: some _ErrorCode
    ) -> Int? {
        errorCodeCatalogDescriptor.integerCode(for: _AnyErrorCode(code))
    }
}

/// Runtime description of a stable error code catalog.
public struct _ErrorCodeCatalogDescriptor: Hashable, Sendable {
    public var catalogIdentifier: String
    public var entries: [_ErrorCodeCatalogEntry]

    public init(
        catalogIdentifier: String,
        entries: [_ErrorCodeCatalogEntry]
    ) {
        self.catalogIdentifier = catalogIdentifier
        self.entries = entries
    }

    public func integerCode(
        for code: _AnyErrorCode
    ) -> Int? {
        entries.first(where: { entry in
            if let lhs = entry.identity, let rhs = code.identity {
                return lhs == rhs
            }

            return entry.stableIdentifier == code.stableIdentifier
        })?.integerCode
    }
}

/// Runtime description of one error code inside a catalog.
public struct _ErrorCodeCatalogEntry: Hashable, Sendable {
    public var stableIdentifier: String
    public var integerCode: Int
    public var identity: _ErrorIdentity?

    public init(
        stableIdentifier: String,
        integerCode: Int,
        identity: _ErrorIdentity? = nil
    ) {
        self.stableIdentifier = stableIdentifier
        self.integerCode = integerCode
        self.identity = identity
    }
}

/// Type-erased view of a declared error code catalog.
public struct _AnyErrorCodeCatalog: Hashable, Sendable {
    public var descriptor: _ErrorCodeCatalogDescriptor
    public var allErrorCodes: [_AnyErrorCode]

    public init(
        descriptor: _ErrorCodeCatalogDescriptor,
        allErrorCodes: [_AnyErrorCode]
    ) {
        self.descriptor = descriptor
        self.allErrorCodes = allErrorCodes
    }

    public init(
        allErrorCodes: [_AnyErrorCode]
    ) {
        self.init(
            descriptor: _ErrorCodeCatalogDescriptor(
                catalogIdentifier: "",
                entries: allErrorCodes.enumerated().map { offset, code in
                    _ErrorCodeCatalogEntry(
                        stableIdentifier: code.stableIdentifier,
                        integerCode: offset + 1,
                        identity: code.identity
                    )
                }
            ),
            allErrorCodes: allErrorCodes
        )
    }

    public init<Catalog: _ErrorCodeCatalogProtocol>(
        _ catalog: Catalog.Type
    ) {
        self.init(
            descriptor: Catalog.errorCodeCatalogDescriptor,
            allErrorCodes: Catalog.allErrorCodes
        )
    }

    public init(
        _ catalog: any _ErrorCodeCatalogProtocol.Type
    ) {
        self.init(
            descriptor: catalog.errorCodeCatalogDescriptor,
            allErrorCodes: catalog.allErrorCodes
        )
    }

    public func integerCode(
        for code: _AnyErrorCode
    ) -> Int? {
        descriptor.integerCode(for: code)
    }
}
