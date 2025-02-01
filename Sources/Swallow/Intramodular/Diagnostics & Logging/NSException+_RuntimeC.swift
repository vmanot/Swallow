//
// Copyright (c) Vatsal Manot
//

private import _RuntimeC
import Foundation

extension NSException {
    @discardableResult
    public static func `catch`<T>(
        callback: () throws -> T
    ) throws -> T {
        var returnValue: T!
        var returnError: Error?
        
        try _Swallow_ExceptionCatcher.catchException {
            do {
                returnValue = try callback()
            } catch {
                returnError = error
            }
        }
        
        if let returnError {
            throw returnError
        }
        
        return returnValue
    }
}
