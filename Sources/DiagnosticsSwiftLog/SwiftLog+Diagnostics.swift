//
// Copyright (c) Vatsal Manot
//

import Diagnostics

import struct Logging.Logger

extension Logger.Message: LogMessageProtocol {

}

extension Logger.Level: ServerLogLevelProtocol {
    public var stringValue: String {
        rawValue
    }
}

extension Logger: ServerLoggerProtocol {
    public typealias LogLevel = Logger.Level
    public typealias LogMessage = Logger.Message

    public func emit(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        let swiftLogMetadata = metadata()?.mapValues(Logger.MetadataValue.init)

        log(
            level: level,
            message(),
            metadata: swiftLogMetadata,
            file: file,
            function: function,
            line: line
        )
    }
}

extension Logger.MetadataValue {
    fileprivate init(_ value: DiagnosticLogMetadataValue) {
        switch value {
        case .string(let value):
            self = .string(value)
        case .array(let values):
            self = .array(values.map(Self.init))
        case .dictionary(let values):
            self = .dictionary(values.mapValues(Self.init))
        }
    }
}
