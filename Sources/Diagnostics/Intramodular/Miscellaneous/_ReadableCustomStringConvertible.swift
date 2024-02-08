//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct _ReadableCustomStringConvertible<Subject>: CustomDebugStringConvertible, CustomStringConvertible, Identifiable {
    public let base: Subject
    public let id: AnyHashable = UUID()

    public var debugDescription: String {
        description
    }
    
    public var description: String {
        guard let base = Optional(_unwrapping: base) else {
            return "Optional<\(Metatype(Subject.self))>(nil)"
        }
        
        if let base = base as? CustomTruncatedStringConvertible {
            return base.truncatedDescription
        } else if let base = base as? CustomStringConvertible {
            return base.description
        } else {
            return Metatype(type(of: base)).name
        }
    }
    
    public init(from base: Subject) {
        self.base = base
    }
}

// MARK: - Conformances

extension _ReadableCustomStringConvertible: HashEquatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        
        if let base = base as? (any Hashable) {
            base.hash(into: &hasher)
        } else {
            hasher.combine(String(describing: base))
        }
    }
}

extension _ReadableCustomStringConvertible: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.description < rhs.description
    }
    
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.description <= rhs.description
    }
}
