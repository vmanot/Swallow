//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Manual fallback for errors that cannot use descriptor-generated causes.
public protocol _ErrorCauseRepresentable {
    var underlyingError: (any Error)? { get }
}

/// Linear primary cause chain from outer error to root cause.
public struct _ErrorChain: Countable, Sendable, Sequence {
    public typealias Element = AnyError

    public var elements: [AnyError]

    public init(elements: [AnyError]) {
        self.elements = elements
    }

    public init(_ error: some Error) {
        self.init(elements: Self._makeElements(from: error))
    }

    public var count: Int {
        elements.count
    }

    public func makeIterator() -> Array<AnyError>.Iterator {
        elements.makeIterator()
    }
}

extension Error {
    public var _errorChain: _ErrorChain {
        _ErrorChain(self)
    }
}

extension _ErrorChain {
    private static let maximumDepth = 64

    private static func _makeElements(
        from error: some Error
    ) -> [AnyError] {
        var result: [AnyError] = []
        var visitedClassErrors: Set<ObjectIdentifier> = []
        var current: (any Error)? = error

        while let error = current, result.count < maximumDepth {
            let base = error._errorXBase

            if let objectIdentifier = _classObjectIdentifier(of: base) {
                guard visitedClassErrors.insert(objectIdentifier).inserted else {
                    break
                }
            }

            result.append(AnyError(erasing: base))

            if let descriptorCause = (base as? any _ErrorDescribed)?._errorDescriptorCase?.underlyingError {
                current = descriptorCause
            } else {
                current = (base as? any _ErrorCauseRepresentable)?.underlyingError
            }
        }

        return result
    }

    private static func _classObjectIdentifier(
        of error: any Error
    ) -> ObjectIdentifier? {
        guard Mirror(reflecting: error).displayStyle == .class else {
            return nil
        }

        return ObjectIdentifier(error as AnyObject)
    }
}
