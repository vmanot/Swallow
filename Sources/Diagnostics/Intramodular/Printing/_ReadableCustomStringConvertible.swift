//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct _ReadableCustomStringConvertible<Subject>: CustomDebugStringConvertible, CustomStringConvertible {
    public let base: Subject
    
    public var debugDescription: String {
        description
    }
    
    public var description: String {
        guard let base = Optional(_unwrapping: base) else {
            return "nil"
        }
        
        if let base = base as? CustomStringConvertible {
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
        if let base = base as? AnyHashable {
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
