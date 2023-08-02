//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _HasPlaceholder {
    typealias _PlaceholderConfiguration = Swallow._UnsafePlaceholderConfiguration<Self>
    
    static var placeholder: Self { get }
    
    init(_placeholder: _PlaceholderConfiguration)
}

public protocol PlaceholderProviding {
    static var placeholder: Self { get }
}

extension PlaceholderProviding where Self: _HasPlaceholder {
    public init(_placeholder: _PlaceholderConfiguration) {
        self = .placeholder
    }
}

// MARK: - Implementation

extension _HasPlaceholder {
    public static var placeholder: Self {
        assert(!_HasPlaceholder_TaskLocalValues._isHasPlaceholderDefaultImplementation)
        
        return _HasPlaceholder_TaskLocalValues.$_isHasPlaceholderDefaultImplementation.withValue(true) {
            self.init(_placeholder: .init())
        }
    }
        
    init(_opaque_placeholder: ()) {
        self.init(_placeholder: .init())
    }
}

extension _HasPlaceholder where Self: Initiable {
    public static var placeholder: Self {
        Self()
    }
    
    public init(_placeholder: _PlaceholderConfiguration) {
        self.init()
    }
}

// MARK: - Auxiliary

public struct _UnsafePlaceholderConfiguration<T>: ExpressibleByNilLiteral {
    internal init() {
        
    }
    
    public init(nilLiteral: ()) {
        
    }
}

struct _HasPlaceholder_TaskLocalValues {
    @TaskLocal static var _isHasPlaceholderDefaultImplementation: Bool = false
}
