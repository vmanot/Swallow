//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct CriticalRuntimeFailure {
    public static func log(_ error: Error, file: StaticString = #file, line: UInt = #line) {
        fatalError(error.localizedDescription, file: file, line: line)
    }
}

public func evaluateWithProcessCriticalScope<T>(_ body: (() throws -> T)) -> T? {
    do {
        return try body()
    } catch {
        CriticalRuntimeFailure.log(error)
        return nil
    }
}
