//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct AnyLocalizedStringResource: @unchecked Sendable, _UnwrappableTypeEraser {
    public typealias _UnwrappedBaseType = LocalizedStringResource
    
    private let base: Either<LocalizedStringResource, String>
    
    public var stringValue: String {
        get throws {
            try base.reduce(
                left: { try $0._toNSLocalizedString() },
                right: { $0 }
            )
        }
    }
    
    public init(_erasing base: LocalizedStringResource) {
        self.base = .left(base)
    }
    
    public func _unwrapBase() -> LocalizedStringResource {
        base.reduce(
            left: { $0 },
            right: { .init(stringLiteral: $0) }
        )
    }
}

// MARK: - Conformances

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension AnyLocalizedStringResource: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type(of: self)))
        
        switch base {
            case .left(let string):
                do {
                    hasher.combine(try string._toNSLocalizedString())
                } catch {
                    assertionFailure(error)
                }
            case .right(let string):
                hasher.combine(string)
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension AnyLocalizedStringResource: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(_erasing: .init(stringLiteral: stringLiteral))
    }
}
