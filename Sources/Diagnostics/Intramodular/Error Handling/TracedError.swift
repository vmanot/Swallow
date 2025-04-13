//
// Copyright (c) Vatsal Manot
//

import Swallow

@frozen
public struct TracedError: CustomStringConvertible, CustomDebugStringConvertible, Error, Hashable, @unchecked Sendable {
    public let base: Error
    
    public var description: String {
        if let base = base as? AnyError {
            assertionFailure()
            
            return base.description
        } else {
            return String(describing: base)
        }
    }
    
    public var localizedDescription: String {
        String(describing: base)
    }
    
    public init(_ error: some Error) {
        self.init(erasing: error)
    }
    
    public init(erasing error: Error) {
        self.base = (error as? AnyError)?.base ?? error
    }
    
    public init?(erasing error: (any Swift.Error)?) {
        guard let error else {
            return nil
        }
        
        self.init(erasing: error)
    }
    
    init(_ base: Error) {
        self.init(erasing: base)
    }
    
    public init(description: String) {
        self.init(CustomStringError(description: description))
    }
    
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(type(of: base)).hash(into: &hasher)
        
        if let value = try? cast(base, to: (any Hashable).self) {
            value.hash(into: &hasher)
        } else {
            String(describing: base).hash(into: &hasher)
        }
    }
    
    public func `throw`() throws -> Never {
        throw base
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
