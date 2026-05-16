//
// Copyright (c) Vatsal Manot
//

import Foundation

extension PassthroughLogger {
    public struct ResolvedTextOutput: Sendable {
        enum Destination: Sendable {
            case standardOutput
            case standardError
            case custom(@Sendable (String) -> Void)
        }
        
        let destination: Destination
        let format: LogEntryTextFormat
        
        public static func standardOutput(
            format: LogEntryTextFormat = .commandLine
        ) -> Self {
            Self(destination: .standardOutput, format: format)
        }
        
        public static func standardError(
            format: LogEntryTextFormat = .commandLine
        ) -> Self {
            Self(destination: .standardError, format: format)
        }
        
        @_spi(Internal)
        public static func custom(
            format: LogEntryTextFormat = .commandLine,
            write: @escaping @Sendable (String) -> Void
        ) -> Self {
            Self(destination: .custom(write), format: format)
        }
        
        func write(
            _ entry: PassthroughLogger.LogEntry
        ) {
            let text = entry.formatted(using: format)
            
            switch destination {
                case .standardOutput:
                    print(text)
                case .standardError:
                    FileHandle.standardError.writeLine(text)
                case .custom(let write):
                    write(text)
            }
        }
    }
}

extension FileHandle {
    fileprivate func writeLine(
        _ line: String
    ) {
        guard let data = (line + "\n").data(using: .utf8) else {
            return
        }
        
        write(data)
    }
}
