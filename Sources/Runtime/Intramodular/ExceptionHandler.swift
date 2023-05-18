//
// Copyright (c) Vatsal Manot
//

import Foundation
import RuntimeShims

public func catchExceptionAsError<Output>(in block: (() throws -> Output)) throws -> Output {
    var result: Result<Output, Error>?
    
    if let exception = NSException.catch(in: { result = Result(catching: block) }) {
        throw ExceptionError(exception)
    } else {
        return try result!.get()
    }
}

public struct ExceptionError: CustomNSError, @unchecked Sendable {
    public let exception: NSException
    public let domain = "com.vmanot.Runtime.catch-exception"
    public let errorUserInfo: [String: Any]
    
    public init(_ exception: NSException) {
        self.exception = exception
        
        if let userInfo = exception.userInfo {
            self.errorUserInfo = [String: Any](uniqueKeysWithValues: userInfo.map { pair in
                (pair.key.description, pair.value)
            })
        } else {
            self.errorUserInfo = [:]
        }
    }
}

extension NSException {
    public static func `catch`(in block: () -> Void) -> Self? {
        catchExceptionOfKind(Self.self, block) as? Self
    }
}
