//
// Copyright (c) Vatsal Manot
//

import Swallow

extension Array: Partializable {
    public typealias Partial = Element
    
    public static func coalesce<S: Sequence>(_ partials: S) -> Self where S.Element == Partial {
        .init(partials)
    }
    
    public static func coalesce<C: Collection>(_ partials: C) -> Self where C.Element == Partial {
        .init(partials)
    }
    
    public mutating func coalesceInPlace(with partial: Partial) throws {
        append(partial)
    }
    
    public mutating func coalesceInPlace<S: Sequence>(withContentsOf partials: S) where S.Element == Partial {
        append(contentsOf: partials)
    }
}

extension ContiguousArray: Partializable {
    public typealias Partial = Element
    
    public static func coalesce<S: Sequence>(_ partials: S) -> Self where S.Element == Partial {
        .init(partials)
    }
    
    public static func coalesce<C: Collection>(_ partials: C) -> Self where C.Element == Partial {
        .init(partials)
    }
    
    public mutating func coalesceInPlace(with partial: Partial) throws {
        append(partial)
    }
    
    public mutating func coalesceInPlace<S: Sequence>(withContentsOf partials: S) where S.Element == Partial {
        append(contentsOf: partials)
    }
}

extension Dictionary: Partializable {
    public typealias Partial = Element
    
    public static func coalesce<S: Sequence>(_ partials: S) -> Self where S.Element == Partial {
        .init(partials)
    }
    
    public static func coalesce<C: Collection>(_ partials: C) -> Self where C.Element == Partial {
        .init(partials)
    }
    
    public mutating func coalesceInPlace(with partial: Partial) {
        append(partial)
    }
    
    public mutating func coalesceInPlace<S: Sequence>(withContentsOf partials: S) where S.Element == Partial {
        append(contentsOf: partials)
    }
}

extension Optional: Partializable where Wrapped: Partializable {
    public typealias Partial = Optional<Wrapped.Partial>
    
    public static func coalesce<S: Sequence>(_ partials: S) throws -> Self where S.Element == Partial {
        return try Wrapped.coalesce(partials.lazy.compactMap({ $0 }))
    }
    
    public mutating func coalesceInPlace(with partial: Partial) throws {
        guard let partial = partial else {
            return
        }
        
        var unwrapped = try unwrap()
        
        try unwrapped.coalesceInPlace(with:partial)
        
        self = .some(unwrapped)
    }
}

extension Result: Partializable where Success: Partializable {
    public typealias Partial = Result<Success.Partial, Failure>
    
    public static func coalesce<S: Sequence>(_ partials: S) throws -> Self where S.Element == Partial {
        let _partials: [Success.Partial]
        do {
            _partials = try partials.map({ try $0.get() })
        } catch {
            return .failure(error as! Failure)
        }
        
        return .success(try Success.coalesce(_partials))
    }
    
    public mutating func coalesceInPlace(with partial: Partial) throws {
        switch (self, partial) {
            case (.success(var lhs), .success(let rhs)):
                try lhs.coalesceInPlace(with: rhs)
                self = .success(lhs)
            case (.failure, _):
                return
            case (_, .failure(let rhs)):
                self = .failure(rhs)
        }
    }
}
