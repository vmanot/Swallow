//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol StaticBool {
    static var value: Bool { get }
}

extension Bool {
    public struct True: StaticBool {
        public static var value: Bool {
            true
        }
    }
    
    public struct False: StaticBool {
        public static var value: Bool {
            false
        }
    }
}

prefix operator &&

public prefix func && <T>(rhs: (@escaping (T) -> Bool)) -> ((Bool, T) -> Bool) {
    return { $0 && rhs($1) }
}
