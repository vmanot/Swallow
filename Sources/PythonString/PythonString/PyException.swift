//
// Copyright (c) Vatsal Manot
//

import Swift

public enum PyException: Swift.Error {
    case attributeError(String)
    case baseException(String)
    case exception(String)
    case valueError(String)
    case keyError(String)
    case indexError(String)
    case typeError(String)
    case systemError(String)
    case overflowError(String)
}

extension PyException: CustomStringConvertible {
    public var description: String {
        switch self {
            case .attributeError(let msg):
                return "AttributeError: \(msg)"
            case .baseException(let msg):
                return "BaseException: \(msg)"
            case .exception(let msg):
                return "Exception: \(msg)"
            case .indexError(let msg):
                return "IndexError: \(msg)"
            case .keyError(let msg):
                return "KeyError: \(msg)"
            case .overflowError(let msg):
                return "OverflowError: \(msg)"
            case .systemError(let msg):
                return "SystemError: \(msg)"
            case .typeError(let msg):
                return "TypeError: \(msg)"
            case .valueError(let msg):
                return "ValueError: \(msg)"
        }
    }
}
