//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift

extension LoggerProtocol where Self: PassthroughLogger {
    @_transparent
    public func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> [String: Any]?,
        file: String,
        function: String,
        line: UInt
    ) {
        if Thread.isMainThread {
            objectWillChange.send()
        } else {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        
        base.log(
            level: level,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }
}
