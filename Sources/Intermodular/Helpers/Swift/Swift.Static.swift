//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Static: AnyProtocol {
    
}

public protocol StaticValue: Static {
    associatedtype Value
    
    static var value: Value { get }
}

public protocol StaticInteger: StaticValue where Value == Int {
    
}

// MARK: - Concrete Implementations -

extension StaticString: Static {
    
}

public struct One: StaticInteger {
    public static let value = 1
}

public struct Two: StaticInteger {
    public static let value = 2
}

public struct Three: StaticInteger {
    public static let value = 3
}

public struct Four: StaticInteger {
    public static let value = 4
}

public struct Five: StaticInteger {
    public static let value = 5
}

public struct Six: StaticInteger {
    public static let value = 6
}

public struct Seven: StaticInteger {
    public static let value = 7
}

public struct Eight: StaticInteger {
    public static let value = 8
}

public struct Nine: StaticInteger {
    public static let value = 9
}

public struct Ten: StaticInteger {
    public static let value = 10
}
