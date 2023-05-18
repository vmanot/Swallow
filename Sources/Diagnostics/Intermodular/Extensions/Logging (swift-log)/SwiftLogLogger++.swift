//
// Copyright (c) Vatsal Manot
//

#if canImport(Logging)
import Logging
import Swift

extension SwiftLogLogger {
    public func log(
        _ error: Error,
        metadata: @autoclosure () -> SwiftLogLogger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .error,
            Logger.Message(String(describing: error)),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }
}
#endif
